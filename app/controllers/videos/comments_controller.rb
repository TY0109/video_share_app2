class CommentsController < ApplicationController
  def create
    @video = Video.find(params[:video_id])
    # videoに紐づいたコメントを作成
    @comment = @video.comments.build(comment_params)
    current_user_types_of_comment
    if @comment.save
      render :index
    else
      flash.now[:danger] = "コメント投稿に失敗しました。"
      render :index
    end
  end

  def update
    @video= Video.find(params[:video_id])
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      flash[:success] = "コメント編集に成功しました。"
    else
      flash[:danger] = "コメント編集に失敗しました。"
    end
      render :index
    end
  end

  def destroy
    @video= Video.find(params[:video_id])
    @comment = Comment.find(params[:id])
    if @comment.destroy
      flash[:success] = "コメント削除に成功しました。"
    else
      flash[:danger] = "コメント削除に失敗しました。"
    end
    render :index
  end

  private
    def comment_params
      params.require(:comment).permit(:comment, :video_id, :organization_id, :user_id, :viewer_id, :loginless_viewer_id).merge(
        organization_id: current_organization.id, user_id: current_user.id, viewer_id: current_viewer.id, loginless_viewer_id: current_loginless_viewer.id
      )
    end

end
