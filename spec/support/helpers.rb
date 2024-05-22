module Helpers
  # vimeoへの投稿をモック化
  def upload_to_vimeo_mock
    # ・vimeo_client = VimeoMe2::User.new(ENV['VIMEO_API_TOKEN'])と、vimeo_video = vimeo_client.upload_video(video_file) の部分
    # → モック化して偽のuriを返す
    # ・self.data_url = vimeo_video['uri'] の部分
    # → モックが返す偽のuriの値がカラムに代入される
    vimeo_user_instance = instance_double(VimeoMe2::User)
    allow(VimeoMe2::User).to receive(:new).and_return(vimeo_user_instance) # newの引数(ENV)は渡していない
    allow(vimeo_user_instance).to receive(:upload_video).and_return('uri' => "/videos/949110689") # upload_videoの引数(video_file)は渡していない
  end

  # vimeoからの動画削除をモック化
  def destroy_from_vimeo_mock
    vimeo_instance = instance_double(VimeoMe2::Video)
    allow(VimeoMe2::Video).to receive(:new).and_return(vimeo_instance)
    allow(vimeo_instance).to receive(:destroy).and_return true # TODO: 本当にtrueを返す仕様か確認が必要
  end
end
