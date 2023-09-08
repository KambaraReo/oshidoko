require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:post) { create(:post) }

  describe "validations" do
    it "タイトル, 関連URL, 説明, 住所, 緯度, 経度, 投稿ユーザーIDが有効な状態であること" do
      post = build(:post, url: "https://tokyo.example.jp", description: "東京駅です。")
      expect(post).to be_valid
    end

    it "タイトルがない場合は無効であること" do
      post = build(:post, title: nil)
      expect(post).to_not be_valid
      expect(post.errors[:title]).to include("は必須項目です")
    end

    it "タイトルが空文字の場合は無効であること" do
      post = build(:post, title: "")
      expect(post).to_not be_valid
      expect(post.errors[:title]).to include("は必須項目です")
    end

    it "タイトルが空白の場合は無効であること" do
      post = build(:post, title: " ")
      expect(post).to_not be_valid
      expect(post.errors[:title]).to include("は必須項目です")
    end

    it "タイトルが31文字以上の場合は無効であること" do
      post = build(:post, title: "a" * 31)
      expect(post).to_not be_valid
      expect(post.errors[:title]).to include("は30文字以内で入力してください")
    end

    it "説明が400文字以上の場合は無効であること" do
      post = build(:post, description: "a" * 401)
      expect(post).to_not be_valid
      expect(post.errors[:description]).to include("は400文字以内で入力してください")
    end

    it "住所がない場合は無効であること" do
      post = build(:post, address: nil)
      expect(post).to_not be_valid
      expect(post.errors[:address]).to include("は必須項目です")
    end

    it "住所が空文字の場合は無効であること" do
      post = build(:post, address: "")
      expect(post).to_not be_valid
      expect(post.errors[:address]).to include("は必須項目です")
    end

    it "住所が空白の場合は無効であること" do
      post = build(:post, address: " ")
      expect(post).to_not be_valid
      expect(post.errors[:address]).to include("は必須項目です")
    end

    it "画像が設定されていれば有効な状態であること" do
      post.pictures.attach(
        io: File.open(Rails.root.join("spec/fixtures/512bytes_sample.png")),
        filename: "512bytes_sample.png",
        content_type: "image/png"
      )
      expect(post).to be_valid
    end

    it "画像のフォーマットが適切でない場合は無効であること" do
      post.pictures.attach(
        io: File.open(Rails.root.join("spec/fixtures/512bytes_sample.gif")),
        filename: "512bytes_sample.gif",
        content_type: "image/gif"
      )
      expect(post).to_not be_valid
      expect(post.errors[:pictures]).to include("のファイル形式はJPEG、JPG、PNGである必要があります。")
    end

    it "画像のファイルサイズが5MB以下でない場合は無効であること" do
      post.pictures.attach(
        io: File.open(Rails.root.join("spec/fixtures/6megabytes_sample.png")),
        filename: "6megabytes_sample.png",
        content_type: "image/png"
      )
      expect(post).to_not be_valid
      expect(post.errors[:pictures]).to include("のファイルサイズは5MB以下である必要があります。")
    end

    it "画像の枚数が3枚以下でない場合は無効であること" do
      post.pictures.attach(
        [
          {
            io: File.open(Rails.root.join("spec/fixtures/512bytes_sample.png")),
            filename: "512bytes_sample.png",
            content_type: "image/png",
          },
          {
            io: File.open(Rails.root.join("spec/fixtures/1megabytes_sample.jpeg")),
            filename: "1megabytes_sample.jpeg",
            content_type: "image/jpeg",
          },
          {
            io: File.open(Rails.root.join("spec/fixtures/2megabytes_sample.png")),
            filename: "2megabytes_sample.png",
            content_type: "image/png",
          },
          {
            io: File.open(Rails.root.join("spec/fixtures/3megabytes_sample.jpg")),
            filename: "3megabytes_sample.jpg",
            content_type: "image/jpg",
          },
        ]
      )
      expect(post).to_not be_valid
      expect(post.errors[:pictures]).to include("は3枚までアップロードできます。")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many_attached(:pictures) }
    it { is_expected.to have_many(:posts_members).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:posts_members) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_many(:favorited_users).through(:favorites).source(:user) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe "#favorited?" do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: create(:user, email: "tester_1@example.com")) }
    let(:other_post) { create(:post, user: create(:user, email: "tester_2@example.com")) }
    let!(:favorite) { Favorite.create(post_id: post.id, user_id: user.id) }

    it "ユーザーがいいねしている投稿を正しく判定できること" do
      expect(post.favorited?(user)).to be_truthy
    end

    it "ユーザーがいいねしていない投稿を正しく判定できること" do
      expect(other_post.favorited?(user)).to be_falsey
    end
  end
end
