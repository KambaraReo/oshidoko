FactoryBot.define do
  factory :member do
    sequence(:name) { |n| "mem._#{n}" }
    generation { 1 }
    is_graduated { false }
  end
end
