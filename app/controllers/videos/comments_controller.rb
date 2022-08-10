class CommentsController < ApplicationController
  def create
    @video = Video.find(params[:video_id])
    # videoに紐づいたコメントを作成
    @comment = @video.comments.build(comment_params)
    current_user_types_of_comment
    if @comment.save
      render template: "videos/videos/show"
    else
      flash.now[:danger] = "コメント投稿に失敗しました。"
      render template: "videos/videos/show"
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      @video= Video.find(params[:video_id])
      flash[:success] = "コメント編集に成功しました。"
    else
      flash[:danger] = "コメント編集に失敗しました。"
    end
      render template: "videos/videos/show"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.destroy
      @video= Video.find(params[:video_id])
      flash[:success] = "コメント削除に成功しました。"
    else
      flash[:danger] = "コメント削除に失敗しました。"
    end
    render template: "videos/videos/show"
  end

  private
    def comment_params
      params.require(:comment).permit(:comment, :video_id, :organization_id, :user_id, :viewer_id, :loginless_viewer_id).merge(
        organization_id: current_organization.id, user_id: current_user.id, viewer_id: current_viewer.id, loginless_viewer_id: current_loginless_viewer.id
      )
    end

    # コメントを投稿するアカウントに応じて保存するidを分ける
    def current_user_types_of_comment
      current_user_type = current_user && current_viewer && current_loginless_viewer
      if current_user_type == current_user
        @comment.user_id = current_user.id
      elsif current_user_type == current_viewer
        @comment.viewer_id = current_viewer.id
      else
        @comment.loginless_viewer_id = current_loginless_viewer.id
      end
    end

end
