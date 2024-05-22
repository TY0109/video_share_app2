class VideosController < ApplicationController
  include CommentReply
  helper_method :account_logged_in?

  before_action :ensure_logged_in, except: :show
  before_action :ensure_user, only: %i[new create]
  before_action :ensure_my_organization_videos, only: %i[index]
  before_action :ensure_my_organization_video, only: %i[show edit update]
  before_action :ensure_admin_or_user, only: %i[edit]
  before_action :ensure_admin_or_owner_or_correct_user, only: %i[update]
  before_action :ensure_admin, only: %i[destroy]

  # TODO: 視聴者がログインしている場合、表示されているビデオの視聴グループ＝現在の視聴者の視聴グループでなければ、視聴できないように修正が必要
  before_action :ensure_logged_in_viewer, only: %i[show]

  before_action :ensure_admin_for_access_hidden, only: %i[show edit update]

  def index
    # 動画検索機能用に記載 リセットボタン、検索ボタン押下後paramsにorganization_idが含まれないためsessionに保存
    @search_params = video_search_params
    session[:organization_id] = params[:organization_id]

    # TODO: 視聴者の視聴グループに紐づくビデオのみを表示するよう修正が必要(第２フェーズで対応予定)
    @organization_videos = current_system_admin ? set_organization_videos : set_organization_videos.available
  end

  def new
    @video = Video.new
    @video.video_folders.build
  end

  def create
    @video = Video.new(video_params)
    @video.identify_organization_and_user(current_user)
    # saveが呼ばれた後のフローは以下
    # ①バリデーションチェックが問題なければ、before_createでvimeoに動画投稿 
    # → ③vimeoへの投稿に成功すれば、videoオブジェクトがcreateされる。/ vimeoへの投稿に失敗すれば、処理を中断
    if @video.save
      flash[:success] = '動画を投稿しました。'
      redirect_to @video
    else
      render :new
    end
  end

  def show
    set_account
    @video = set_video
    # showページでrenderしている partial: 'comments/index' 内で使用
    @comments = @video.comments.includes(:system_admin, :user, :viewer, :replies).order(created_at: :desc)
    # showページでrenderしている partial: 'comments/form' 内で使用
    @comment = Comment.new
    # partial: 'comments/index' の中でrenderしている partial: 'replies/form' 内で使用
    @reply = Reply.new
  end

  def edit
    @video = set_video
  end

  def update
    @video = set_video
    if @video.update(video_params)
      flash[:success] = '動画情報を更新しました'
      redirect_to video_url
    else
      render :edit
    end
  end

  def destroy
    video = set_video
    # TODO: モデルファイルへの移行と、例外捕捉も必要。また、vimeoから動画が削除できていることを表すフラグとしてカラムを追加したい
    VimeoMe2::Video.new(ENV['VIMEO_API_TOKEN'], video.data_url).destroy
    video.destroy
    flash[:success] = '削除しました'
    redirect_to videos_url(organization_id: video.organization.id)
  end

  private

  def video_params
    params.require(:video).permit(:title, :video_file, :open_period, :range, :comment_public, :login_set, :popup_before_video, :popup_after_video, { folder_ids: [] })
  end

  def video_search_params
    params.fetch(:search, {}).permit(:title_like, :open_period_from, :open_period_to, :range, :user_name)
  end

  def set_video
    Video.find(params[:id])
  end
  
  # organization::foldersコントローラにも定義あり
  def set_organization
    Organization.find(params[:organization_id])
  end

  def ensure_user
    # organization::foldersコントローラにも同名のメソッドがあるが、遷移先は異なる
    redirect_to root_url, flash: { danger: '権限がありません' }  unless current_user
  end

  def set_organization_videos
    Video.organization_specific_videos(params[:organization_id])
  end

  # TODO: my_organization? と、one_of_my_organization? は、VideoクラスとOrganizationクラスに定義してあるが、1つにまとめたい
  def ensure_my_organization_videos
    if current_user
      unless set_organization.my_organization?(current_user)
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    elsif current_viewer
      unless set_organization.one_of_my_organization?(current_viewer)
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end
  
  # TODO: my_organization? と、one_of_my_organization? は、VideoクラスとOrganizationクラスに定義してあるが、1つにまとめたい
  def ensure_my_organization_video
    if current_user
      unless set_video.my_organization?(current_user)
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    elsif current_viewer
      unless set_video.one_of_my_organization?(current_viewer)
        flash[:danger] = '権限がありません。'
        redirect_back(fallback_location: root_url)
      end
    end
  end
  
  def ensure_admin_or_owner_or_correct_user
    unless current_system_admin? || set_video.my_upload?(current_user) || current_user&.owner?
      redirect_to video_url, flash: { danger: '権限がありません。' }
    end
  end

  def ensure_logged_in_viewer
    redirect_to new_viewer_session_url, flash: { danger: '視聴者ログインしてください。' } if !logged_in? && set_video.login_set?
  end

  def ensure_admin_for_access_hidden
    if current_system_admin.nil? && !set_video.is_valid?
      flash[:danger] = 'すでに削除された動画です。'
      redirect_back(fallback_location: root_url)
    end
  end
end
