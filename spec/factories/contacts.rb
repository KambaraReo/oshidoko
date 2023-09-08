FactoryBot.define do
  factory :contact do
    name { "tester" }
    email { "tester@example.com" }
    content { "お問い合わせです。" }
  end
end
