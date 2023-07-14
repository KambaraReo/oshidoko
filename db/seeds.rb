members_data = [
  ['井口眞緒', 1 , 'true'],
  ['潮紗理菜', 1 , 'false'],
  ['柿崎芽実', 1 , 'true'],
  ['影山優佳', 1 , 'false'],
  ['加藤史帆', 1 , 'false'],
  ['齊藤京子', 1 , 'false'],
  ['佐々木久美', 1 , 'false'],
  ['佐々木美玲', 1 , 'false'],
  ['高瀬愛奈', 1 , 'false'],
  ['高本彩花', 1 , 'false'],
  ['東村芽依', 1 , 'false'],
  ['金村美玖', 2 , 'false'],
  ['河田陽菜', 2 , 'false'],
  ['小坂菜緒', 2 , 'false'],
  ['富田鈴花', 2 , 'false'],
  ['丹生明里', 2 , 'false'],
  ['濱岸ひより', 2 , 'false'],
  ['松田好花', 2 , 'false'],
  ['宮田愛萌', 2 , 'true'],
  ['渡邉美穂', 2 , 'true'],
  ['上村ひなの', 3 , 'false'],
  ['髙橋未来虹', 3 , 'false'],
  ['森本茉莉', 3 , 'false'],
  ['山口陽世', 3 , 'false'],
  ['石塚瑶季', 4 , 'false'],
  ['岸帆夏', 4 , 'false'],
  ['小西夏菜実', 4 , 'false'],
  ['清水理央', 4 , 'false'],
  ['正源司陽子', 4 , 'false'],
  ['竹内希来里', 4 , 'false'],
  ['平尾帆夏', 4 , 'false'],
  ['平岡海月', 4 , 'false'],
  ['藤嶌果歩', 4 , 'false'],
  ['宮地すみれ', 4 , 'false'],
  ['山下葉留花', 4 , 'false'],
  ['渡辺莉奈', 4 , 'false']
]

members_data.each do |name, gen, graduation|
  Member.create!(
    { name: name, generation: gen, is_graduated: graduation }
  )
end
