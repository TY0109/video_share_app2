FactoryBot.define do
  factory :comment do
    comment { "MyText" }
    user { nil }
    viewer { nil }
    loginless_viewer { nil }
    organization { nil }
    video { nil }
  end
end
