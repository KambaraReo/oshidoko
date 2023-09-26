FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "tester_#{n}" }
    sequence(:email) { |n| "tester_#{n}@example.com" }
    password { "password123" }

    trait :with_icon do
      icon do
        {
          io: File.open("#{Rails.root}/spec/fixtures/512bytes_sample.png"),
          filename: "512bytes_sample.png",
          content_type: "image/png",
        }
      end
    end
  end
end
