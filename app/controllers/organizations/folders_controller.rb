class Organizations::FoldersController < ApplicationController
  layout 'organizations'

  def index
    @folders = Folder.current_owner_has(current_user)
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

  private

  def folder_params
    params.require(:folder).permit(:name).merge(organization_id: current_user.organization_id)
  end

end
