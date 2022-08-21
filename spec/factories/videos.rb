FactoryBot.define do
  factory :video do
    id { 1 }
    title { 'あああ' }
    open_period { 'Sun, 14 Aug 2022 18:06:00.000000000 JST +09:00' }
    range { false }
    comment_public { false }
    popup_before_video { false }
    popup_after_video { false }
    organization_id { 1 }
    user_id { 1 }

    after(:build) do |video|
      video.video.attach(io: File.open('spec/fixtures/files/rec.webm'), filename: 'rec.webm', content_type: 'video/webm')
    end

    association :organization
    association :user
  end
end
