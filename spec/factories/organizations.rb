FactoryBot.define do
  factory :organization, class: 'Organization' do
    id             { 1 }
    name           { 'セレブエンジニア' }
  end

  factory :another_organization, class: 'Organization' do
    id             { 2 }
    name           { 'テックリーダーズ' }
  end
end
