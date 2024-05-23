class Viewers::VideoStatusesController < ApplicationController
  # リファクタリング案
  # → viewers_controller.rb記載のbefore_action :ensure_logged_inと、ensure_admin_or_user, ensure_adminをviewers::base.rbに記載し、Viewers::VideoStatusesController < Viewers::Base
  include Viewers::VideoStatusesHelper
  layout 'video_statuses'

  before_action :ensure_logged_in
  before_action :ensure_admin_or_user, only: %i[index]
  before_action :ensure_viewer, only: %i[update]
  before_action :ensure_my_organization_video, only: %i[index]
  before_action :ensure_admin, only: %i[destroy]

  def index
    @video = set_video
    @viewers = set_viewers
    # 視聴完了している視聴者とその割合
    @complete_viewers = set_viewers.completely_watched(set_video)
    @complete_viewers_rate = ((@complete_viewers.count / set_viewers.count) * 100).round(0)
    # 視聴状況が作成されていない場合は、視聴率が0.0%のオブジェクトを生成
    set_video_statuses
    # 視聴率が100.0%未満のオブジェクトをグラフ表示
    make_graph
  end

  def update
    start_point_param = params[:video_status][:start_point].to_i
    end_point_param = params[:video_status][:end_point].to_i
    total_time_param = params[:video_status][:total_time].to_i

    video_status = set_video_status

    # すでに保存されている再生完了時点 < 新たにとんでくる再生開始時点 の場合は保存を行わない ← とばし再生防止
    return if video_status.incorrect_latest_start_point?(start_point_param)
    # すでに保存されている再生完了時点 < 新たに送られてくる再生完了時点 の場合にのみ保存を行う。← 同じ部分を繰り返し視聴する場合には、保存しないようにするための対応
    if video_status.correct_latest_end_point?(end_point_param)
      ActiveRecord::Base.transaction do
        video_status.update!(video_status_params.merge(watched_ratio: calculate_watched_ratio(total_time_param, end_point_param)))
        video_status.update!(watched_at: Time.current) if video_status.completely_watched?
      end
    end
  end

  def destroy
    set_video_status.destroy!
    flash[:success] = '削除しました。'
    redirect_to video_statuses_url(set_video)
  end

  private

  def video_status_params
    params.require(:video_status).permit(:total_time, :end_point, :video_id, :viewer_id)
  end

  def set_video
    Video.find(params[:id])
  end

  def set_viewers
    if current_user
      Viewer.viewer_has(set_video.organization.id).subscribed
    elsif current_system_admin
      Viewer.viewer_has(set_video.organization.id)
    end
  end

  def set_video_status
    VideoStatus.find(params[:id])
  end

  def set_video_statuses
    video = set_video
    ActiveRecord::Base.transaction do
      set_viewers.each do |viewer|
        unless viewer.video_statuses.find_by(video_id: video.id).present?
          viewer.video_statuses.create!(video_id: video.id, watched_ratio: 0.0)
        end
      end
    end
  end

  def make_graph
    # 横軸に視聴者の名前
    @side = []
    # 縦軸に視聴率
    @vertical = []

    set_viewers.each do |viewer|
      video_status = viewer.video_statuses.find_by(video_id: set_video.id)
      unless video_status.completely_watched?
        @side.push(viewer.name)
        @vertical.push(video_status.watched_ratio)
      end
    end
  end

  def ensure_viewer
    unless current_viewer
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
  
  # TODO: 組織外の視聴者も制御したい
  def ensure_my_organization_video
    if current_user?
      unless set_video.my_organization?(current_user)
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end
end
