class VimeoClient
  def initialize(api_token = ENV['VIMEO_API_TOKEN'])
    # video.rbで VimeoClient.new されたと同時に以下が実行される
    @vimeo_client = VimeoMe2::User.new(api_token)
  end

  def upload(video_file)
    # initializeで生成された@vimeo_clientに対してupload_videoメソッドを呼び出す
    vimeo_video = @vimeo_client.upload_video(video_file)
    vimeo_video['uri']
  end
end
