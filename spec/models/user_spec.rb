require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "ユーザーネーム, メールアドレス, パスワードが有効な状態であること" do
      expect(user).to be_valid
    end

    it "ユーザーネームがない場合は無効であること" do
      user = build(:user, username: nil)
      expect(user).to_not be_valid
      expect(user.errors[:username]).to include("を入力してください")
    end

    it "ユーザーネームが空文字の場合は無効であること" do
      user = build(:user, username: "")
      expect(user).to_not be_valid
      expect(user.errors[:username]).to include("を入力してください")
    end

    it "ユーザーネームが空白の場合は無効であること" do
      user = build(:user, username: " ")
      expect(user).to_not be_valid
      expect(user.errors[:username]).to include("を入力してください")
    end

    it "ユーザーネームが16文字以上の場合は無効であること" do
      user = build(:user, username: "a" * 16)
      expect(user).to_not be_valid
      expect(user.errors[:username]).to include("は15文字以内で入力してください")
    end

    it "メールアドレスがない場合は無効であること" do
      user = build(:user, email: nil)
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "メールアドレスが空文字の場合は無効であること" do
      user = build(:user, email: "")
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "メールアドレスが空白の場合は無効であること" do
      user = build(:user, email: " ")
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "既に使用されているメールアドレスの場合は無効であること" do
      user = create(:user)
      other_user = build(:user)
      expect(other_user).to_not be_valid
      expect(other_user.errors[:email]).to include("はすでに存在します")
    end

    it "パスワードがない場合は無効であること" do
      user = build(:user, password: nil)
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "パスワードが空文字の場合は無効であること" do
      user = build(:user, password: "")
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "パスワードが空白の場合は無効であること" do
      user = build(:user, password: " ")
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "パスワードが5文字以下の場合は無効であること" do
      user = build(:user, password: "12345")
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("は6文字以上で入力してください")
    end

    it "パスワードが21文字以上の場合は無効であること" do
      user = build(:user, password: "123" * 7)
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("は20文字以内で入力してください")
    end

    it "パスワードとパスワード(確認)が不一致の場合は無効であること" do
      user = build(:user, password_confirmation: "passward123")
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
    end

    it "プロフィールが設定されていれば有効な状態であること" do
      user = build(:user, introduction: "私のプロフィールです。")
      expect(user).to be_valid
    end

    it "プロフィールが201文字以上の場合は無効であること" do
      user = build(:user, introduction: "私のプロフィールです" * 20 + "。")
      expect(user).to_not be_valid
      expect(user.errors[:introduction]).to include("は200文字以内で入力してください")
    end

    it "アイコンが設定されていれば有効な状態であること" do
      user.icon.attach(io: File.open(Rails.root.join("spec/fixtures/512bytes_sample.png")), filename: "512bytes_sample.png", content_type: "image/png")
      expect(user).to be_valid
    end

    it "アイコンのフォーマットが適切でない場合は無効であること" do
      user.icon.attach(io: File.open(Rails.root.join("spec/fixtures/512bytes_sample.gif")), filename: "512bytes_sample.gif", content_type: "image/gif")
      expect(user).to_not be_valid
      expect(user.errors[:icon]).to include("のファイル形式はJPEG、JPG、PNGである必要があります。")
    end

    it "アイコンのファイルサイズが1MB以下でない場合は無効であること" do
      user.icon.attach(io: File.open(Rails.root.join("spec/fixtures/2megabytes_sample.png")), filename: "2megabytes_sample.png", content_type: "image/png")
      expect(user).to_not be_valid
      expect(user.errors[:icon]).to include("のファイルサイズは1MB以下である必要があります。")
    end
  end

  describe "associations" do
    it { is_expected.to have_one_attached(:icon) }
    it { is_expected.to have_many(:users_members).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:users_members) }
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:favorites).dependent(:destroy) }
    it { is_expected.to have_many(:favorited_posts).through(:favorites).source(:post) }
    it { is_expected.to have_many(:followers).class_name("Relationship").with_foreign_key("follower_id").dependent(:destroy) }
    it { is_expected.to have_many(:followeds).class_name("Relationship").with_foreign_key("followed_id").dependent(:destroy) }
    it { is_expected.to have_many(:following_users).through(:followers).source(:followed) }
    it { is_expected.to have_many(:follower_users).through(:followeds).source(:follower) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe "#update_without_current_password" do
    subject { user.update_without_current_password(params) }

    context "ユーザーがパスワード以外のユーザー情報を変更する時" do
      let(:params) { { email: "new_tester@example.com" } }

      it "現在のパスワードを入力しないでユーザー情報が更新されること" do
        expect { subject }.to change { user.reload.email }.from(user.email).to(params[:email])
      end

      it "skip_reconfirmation!メソッドが呼び出されること" do
        expect(user).to receive(:skip_reconfirmation!)
        subject
      end
    end

    context "ユーザーがパスワードを含むユーザー情報を変更する時" do
      context "適切な現在のパスワードを入力した場合" do
        let(:params) do
          {
            email: "new_tester@example.com",
            password: "password789",
            current_password: "password123"
          }
        end

        it "ユーザー情報が更新されること" do
          expect { subject }.to change { user.reload.email }.from(user.email).to(params[:email])
        end

        it "skip_reconfirmation!メソッドが呼び出されること" do
          expect(user).to receive(:skip_reconfirmation!)
          subject
        end
      end

      context "誤った現在のパスワードを入力した場合" do
        let(:params) do
          {
            email: "new_tester@example.com",
            password: "password789",
            current_password: "passward123"
          }
        end

        it "ユーザー情報が更新されないこと" do
          expect { subject }.not_to change { user.reload.email }
        end
      end
    end
  end

  describe "#follow" do
    let(:other_user) { create(:user, username: "other_tester", email: "other_tester@example.com") }

    it "フォローできること" do
      expect { user.follow(other_user.id) }.to change { Relationship.count }.by(1)
    end
  end

  describe '#unfollow' do
    let(:other_user) { create(:user, username: "other_tester", email: "other_tester@example.com") }

    it "フォローを外せること" do
      user.follow(other_user.id)
      expect { user.unfollow(other_user.id) }.to change { Relationship.count }.by(-1)
    end
  end

  describe "#following?" do
    let(:other_user) { create(:user, username: "other_tester", email: "other_tester@example.com") }

    it "フォローしているユーザーを正しく判定できること" do
      user.follow(other_user.id)
      expect(user.following?(other_user)).to be_truthy
    end

    it "フォローしていないユーザーを正しく判定できること" do
      expect(user.following?(other_user)).to be_falsey
    end
  end
end
