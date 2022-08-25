class RepliesController < ApplicationController

  def create
    @video = Video.find(params[:video_id])
    @comment = Comment.find(params[:comment_id])
    # videoに紐づいたコメントを取得
    @comments = @video.comments.order(created_at: :desc)
    @reply = @comment.replies.build(reply_params)
    @replies = @comment.replies.order(created_at: :desc)
    # set_replyer_id
    if @reply.save
      flash.now[:success] = "コメント返信に成功しました。"
    else
      flash.now[:danger] = "コメント返信に失敗しました。"
    end
    render template: "comments/_index"
  end

  def update
    @comment = Comment.find(params[:comment_id])
    @reply = Reply.find(params[:id])
    if @reply.update(eply_params)
      flash[:success] = "コメント返信編集に成功しました。"
    else
      flash[:danger] = "コメント返信編集に失敗しました。"
    end
    render template: "videos/show"
  end

  def destroy
    @comment = Comment.find(params[:id])
    @reply = Reply.find(params[:id])
    if @comment.destroy
      flash[:success] = "コメント返信削除に成功しました。"
    else
      flash[:danger] = "コメント削除返信に失敗しました。"
    end
    render template: "videos/show"
  end

  private
    def reply_params
      params.require(:reply).permit(:reply, :video_id, :comment_id, :organization_id).merge(
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
    def set_replyer_id
      current_user_type = (current_user || current_viewer || current_loginless_viewer)
      if current_user_type == current_user
        @reply.user_id = current_user.id
      elsif current_user_type == current_viewer
        @reply.viewer_id = current_viewer.id
      else
        @reply.loginless_viewer_id = current_loginless_viewer.id
      end
    end

end