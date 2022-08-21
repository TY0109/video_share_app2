require 'rails_helper'

RSpec.describe Video, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  it 'タイトル、ビデオ、公開期間、動画公開範囲、コメント公開範囲、ログイン有無設定、動画視聴開始時ポップアップ表示、動画視聴終了時ポップアップ表示、組織idがある場合、動画投稿者idがある場合に有効である。' do
    # videoの投稿時に、organization_idとuser_idも必要なので、それぞれのインスタンスをDBに登録
    FactoryBot.create(:organization)
    FactoryBot.create(:user)
    video = FactoryBot.create(:video)

    expect(video).to be_valid
  end

  it 'タイトルがない場合、無効である' do
    FactoryBot.create(:organization)
    FactoryBot.create(:user)
    # validaかinvalidかの判断はDB登録以前に行うのでcreateではなくbuild
    video = FactoryBot.build(:video, title: nil)
    video.valid?
    # expect(video).to be_invalid
    expect(video.errors[:title]).to include('を入力してください')
  end

  it 'ビデオがない場合、無効である' do
    FactoryBot.create(:organization)
    FactoryBot.create(:user)
    video = Video.new(id: 1,
      title: 'あああ',
      open_period: 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00',
      range: false,
      comment_public: false,
      popup_before_video: false,
      popup_after_video: false,
      organization_id: 1,
      user_id: 1
    )
    video.valid?
    # expect(video).to be_invalid
    expect(video.errors[:video]).to include('を入力してください')
  end
end
