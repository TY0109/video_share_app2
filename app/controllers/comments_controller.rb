class CommentsController < ApplicationController
  
  def create
    @video = Video.find(params[:video_id])
    # videoに紐づいたコメントを作成
    @comment = @video.comments.build(comment_params)
    @reply = Reply.new
    # videoに紐づいたコメントを取得
    @comments = @video.comments.order(created_at: :desc)
    # set_commenter_id
    if @comment.save
      flash.now[:success] = "コメント投稿に成功しました。"
    else
      flash.now[:danger] = "コメント投稿に失敗しました。"
    end
    render template: "comments/_index"
  end

  def update
    @video= Video.find(params[:video_id])
    @comment = Comment.find(params[:id])
    if @comment.update(comment_params)
      flash[:success] = "コメント編集に成功しました。"
    else
      flash[:danger] = "コメント編集に失敗しました。"
    end
    render template: "videos/show"
  end

  def destroy
    @video= Video.find(params[:video_id])
    @comment = Comment.find(params[:id])
    if @comment.destroy
      flash[:success] = "コメント削除に成功しました。"
    else
      flash[:danger] = "コメント削除に失敗しました。"
    end
    render template: "videos/show"
  end

  private
    def comment_params
      params.require(:comment).permit(:comment, :video_id, :organization_id).merge(
        organization_id: @video.organization_id, user_id: 1, viewer_id: 1, loginless_viewer_id: 1 # 仮でidを1に設定
      )
    end

    # 試作
    # def comment_params
      # params.require(:comment).permit(:comment, :video_id, :organization_id, :user_id, :viewer_id, :loginless_viewer_id).merge(
        # organization_id: @video.organization_id, user_id: current_user.id, viewer_id: current_viewer.id, loginless_viewer_id: current_loginless_viewer.id
      # )
    # end

    # コメントしたアカウントのidをセット
    def set_commenter_id
      current_user_type = (current_user || current_viewer || current_loginless_viewer)
      if current_user_type == current_user
        @comment.user_id = current_user.id
      elsif current_user_type == current_viewer
        @comment.viewer_id = current_viewer.id
      else
        @comment.loginless_viewer_id = current_loginless_viewer.id
      end
    end

end
