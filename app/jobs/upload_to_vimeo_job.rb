class UploadToVimeoJob < ApplicationJob
  require_relative '../../lib/api/vimeo_client'

  queue_as :default

  def perform(video)
    # vimeoに投稿し、完了できていればtrueを返す。
    # cf https://github.com/bo-oz/vimeo_me2
    vimeo_client = VimeoClient.new
    video.data_url = vimeo_client.upload(video.video_file)
    video.save!
  rescue VimeoMe2::RequestFailed => e
    # TODO: 通知処理
  end
end
