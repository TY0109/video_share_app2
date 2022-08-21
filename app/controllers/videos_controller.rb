class VideosController < ApplicationController
  before_action :authenticate_user!, except: :show
  # before_actionは今後詰めていく必要あり
  before_action :set_video, only: %i[show edit update destroy]

  def index
    @videos = Video.all
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      # 今後必要に応じてファイル形式変換処理
      # ConvertVideoJob.perform_later(@video.id)
      # snip response boilerplate
      flash[:success] = '動画を投稿しました。'
      redirect_to videos_url
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update; end

  def destroy
    @video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_path
  end

  private

  def video_params
    params.require(:video).permit(:title, :video, :open_period, :range, :comment_public, :login_set, :popup_before_video,
      :popup_after_video, :organization_id, :user_id)
  end

  def set_video
    @video = Video.find(params[:id])
  end
end
