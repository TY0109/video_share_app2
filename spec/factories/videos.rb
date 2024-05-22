FactoryBot.define do
  factory :video_sample, class: 'Video' do
    id { 1 }
    title { 'サンプルビデオ' }
    open_period { Time.now + 1 }
    # organization, user という書き方で紐づけると、specファイルでvideoをcreateした時に、organization, userがcreateされてしまう。
    # user, organizationはlet!ですでに作成済みなので、新たに作成する必要はない。※ 新たに作成しようとすると、メアドの一意制約に反しエラーになる
    organization_id { 1 }
    user_id { 1 }
  end

  factory :video_test, class: 'Video' do
    id { 2 }
    title { 'テストビデオ' }
    open_period { Time.now + 1 }
    organization_id { 1 }
    user_id { 1 }
  end

  factory :video_popup_before_test, class: 'Video' do
    title { 'テストビデオ1' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { true }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_popup_after_test, class: 'Video' do
    title { 'テストビデオ2' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { false }
    popup_before_video { false }
    popup_after_video { true }
    organization_id { 1 }
    user_id { 3 }
    organization
    user
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end

  factory :video_it, class: 'Video' do
    title { 'ITビデオ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    login_set { true }
    popup_before_video { false }
    popup_after_video { false }
    # vimeoへの動画データのアップロードは行わず。(vimeoに動画データがなくても、data_urlを仮で設定しておけば、アプリ内ではインスタンスが存在可能)
    data_url { '/videos/222222222' }
  end
end
