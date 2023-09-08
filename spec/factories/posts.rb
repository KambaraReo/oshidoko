FactoryBot.define do
  factory :post do
    title { "東京駅" }
    address { "〒100-0005 東京都千代田区丸の内１丁目" }
    latitude { "35.681382" }
    longitude { "139.76608399999998" }

    user
  end
end
