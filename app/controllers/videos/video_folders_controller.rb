class Videos::VideoFoldersController < VideosController
  before_action :ensure_admin_or_owner_or_correct_user
  before_action :ensure_my_organization_video
  skip_before_action :ensure_admin

  def destroy
    # video_folder = Folder.find_by(folder_id: params[:folder_id], video_id: params[:video_id])で取得することもできるが、folderを変数化したいため、以下のように対応
    folder = Folder.find(params[:folder_id])
    video_folder = folder.video_folders.find_by(video_id: params[:video_id])
    video_folder.destroy
    redirect_to organization_folder_url(folder, organization_id: params[:organization_id]), flash: { danger: '動画をフォルダ内から削除しました' }
  end

  private

  def set_video
    Video.find(params[:video_id])
  end

  def ensure_admin_or_owner_or_correct_user
    # videosコントローラのメソッドとほぼ同じ処理(リダイレクト先のみ異なる)
    unless current_system_admin? || set_video.my_upload?(current_user) || current_user&.owner?
      redirect_to organization_folders_url(params[:organization_id]), flash: { danger: '権限がありません。' }
    end
  end
end
