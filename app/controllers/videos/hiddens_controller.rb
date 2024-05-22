# TODO Videos::HiddensController < Videos::Base のように変更したい
class Videos::HiddensController < VideosController
  before_action :ensure_admin_or_user
  before_action :ensure_admin_or_owner
  before_action :ensure_my_organization_video

  def confirm
    @video = set_video
  end

  def withdraw
    @video = set_video
    if @video.update(is_valid: false)
      flash[:success] = '削除しました'
      redirect_to videos_url(organization_id: @video.organization.id)
    else
      render :confirm
    end
  end

  private

  # organization::foldersコントローラに定義してあるメソッドと処理は実質同じ
  def ensure_admin_or_owner
    redirect_to users_url, flash: { danger: '権限がありません' } unless current_system_admin || current_user.owner?
  end
end
