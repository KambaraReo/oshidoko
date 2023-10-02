FactoryBot.define do
  factory :comment do
    comment { "コメントです。" }
    rate { 5 }
  end
end
