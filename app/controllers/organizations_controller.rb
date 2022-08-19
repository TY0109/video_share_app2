class OrganizationsController < ApplicationController
  before_action :set_organization, except: %i[new create]

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      flash[:success] = "#{@organization.name}の作成に成功しました"
      redirect_to organization_url
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @organization.update(organization_params)
      flash[:success] = '更新しました'
      redirect_to organization_url
    else
      render 'edit'
    end
  end

  def destroy
    @organization.destroy!
    flash[:danger] = "#{@organization.name}のユーザー情報を削除しました"
    redirect_to organization_url
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :email)
  end

  def set_organization
    @organization = Organization.find(params[:id])
  end
end
