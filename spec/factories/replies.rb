FactoryBot.define do
  factory :reply do
    reply { "MyText" }
    organization { nil }
    user { nil }
    viewer { nil }
    loginless_viewer { nil }
    comment { nil }
  end
end
