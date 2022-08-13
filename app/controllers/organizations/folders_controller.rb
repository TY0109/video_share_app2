class Organizations::FoldersController < ApplicationController
  layout 'organizations'

  def index
    @folders = Folder.current_owner_has(current_user)
  end

  def new
    @folder = Folder.new
  end

  def create
  end
end
