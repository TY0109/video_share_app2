class VideosController < ApplicationController

  def show
    @video = Video.find(params[:id])
    @user = @video.user
    @comment = Comment.new
    # 新着順で表示
    @comments = @video.comments.order(created_at: :desc)
    @replies = Reply.where(video_id: @video.id.comments.ids)
  end

end