class CommentsController < ApplicationController
  include CommentReply
  before_action :ensure_system_admin_or_user_or_viewer
  before_action :correct_system_admin_or_user_or_viewer_comment, only: %i[update destroy]
  before_action :account_logged_in?
  helper_method :account_logged_in?

  def create
    set_video_id
    @comment = @video.comments.build(comment_params)
    # コメント投稿したアカウントをセット
    set_commenter_id
    if @comment.save
      flash.now[:success] = 'コメント投稿に成功しました。'
    else
      flash.now[:danger] = 'コメント投稿に失敗しました。'
    end
    @reply = Reply.new
    render :index
  end

  def update
    set_commenter_id
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      flash.now[:success] = 'コメント編集に成功しました。'
    else
      flash.now[:danger] = 'コメント編集に失敗しました。'
    end
    @reply = Reply.new
    render :index
  end

  def destroy
    set_video_id
    set_commenter_id
    @comment = Comment.find(params[:id])
    if @comment.destroy
      flash.now[:success] = 'コメント削除に成功しました。'
    else
      flash.now[:danger] = 'コメント削除に失敗しました。'
    end
    @reply = Reply.new
    render :index
  end

  private

  def comment_params
    params.require(:comment).permit(:comment).merge(
      organization_id: @video.organization_id
    )
  end

  # コメントしたアカウントidをセット
  def set_commenter_id
    if current_system_admin
      @comment.system_admin_id = current_system_admin.id
    elsif current_user
      @comment.user_id = current_user.id
    elsif current_viewer
      @comment.viewer_id = current_viewer.id
    end
  end

  # システム管理者またはコメントした動画投稿者本人、動画視聴者本人のみ許可
  def correct_system_admin_or_user_or_viewer_comment
    @comment = Comment.find(params[:id])
    set_video_id
    if !current_system_admin && (@comment.user_id != current_user&.id || @comment.viewer_id != current_viewer&.id)
      redirect_to video_url(@video.id), flash: { danger: '権限がありません' }
    end
  end
end
