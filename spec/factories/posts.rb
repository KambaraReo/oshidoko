FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "title_#{n}" }
    sequence(:address) { |n| "〒000-0000 address_#{n}" }
    sequence(:latitude) { |n| "35.#{n}" }
    sequence(:longitude) { |n| "139.#{n}" }

    user

    transient do
      members_count { 3 }
    end

    after(:create) do |post, evaluator|
      post.members << create_list(:member, evaluator.members_count)
    end
  end
end
