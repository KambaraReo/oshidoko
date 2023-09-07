FactoryBot.define do
  factory :user do
    username { "tester" }
    email { "tester@example.com" }
    password { "password123" }
  end
end
