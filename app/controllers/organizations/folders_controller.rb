class Organizations::FoldersController < ApplicationController
  layout 'organizations'

  before_action :ensure_owner
  before_action :set_folder, only: [:show, :update, :destroy]

  def index
    @folders = Folder.current_owner_has(current_user)
  end

  def show
  end

  def new
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(folder_params)
    if @folder.save
      redirect_to folders_path, flash: { success: 'フォルダを作成しました！' }
    else
      render "new"
    end
  end

  def update
    @folders = Folder.current_owner_has(current_user)
    if @folder.update(folder_params)
      redirect_to folders_path
    else
      flash[:danger] = "フォルダ名が空欄、もしくは同じフォルダ名があります。"
      redirect_to folders_path
    end
  end

  def destroy
    if @folder.destroy
      flash[:danger] = "フォルダを削除しました"
      redirect_to folders_path
    else
      render "index"
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:name).merge(organization_id: current_user.organization_id)
  end

  def set_folder
    @folder = Folder.find(params[:id])
  end

  def ensure_owner
    if current_user.role != "owner"
      flash[:danger]="権限がありません"
      redirect_to users_dash_boards_path
    end
  end
end
