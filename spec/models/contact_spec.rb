require 'rails_helper'

RSpec.describe Contact, type: :model do
  let(:contact) { create(:contact) }

  describe "validations" do
    it "名前, メールアドレス, お問い合わせ内容が有効な状態であること" do
      expect(contact).to be_valid
    end

    it "名前がない場合は無効であること" do
      contact = build(:contact, name: nil)
      expect(contact).to_not be_valid
      expect(contact.errors[:name]).to include("は必須項目です")
    end

    it "名前が空文字の場合は無効であること" do
      contact = build(:contact, name: "")
      expect(contact).to_not be_valid
      expect(contact.errors[:name]).to include("は必須項目です")
    end

    it "名前が空白の場合は無効であること" do
      contact = build(:contact, name: " ")
      expect(contact).to_not be_valid
      expect(contact.errors[:name]).to include("は必須項目です")
    end

    it "名前が21文字以上の場合は無効であること" do
      contact = build(:contact, name: "a" * 21)
      expect(contact).to_not be_valid
      expect(contact.errors[:name]).to include("は20文字以内で入力してください")
    end

    it "メールアドレスがない場合は無効であること" do
      contact = build(:contact, email: nil)
      expect(contact).to_not be_valid
      expect(contact.errors[:email]).to include("は必須項目です")
    end

    it "メールアドレスが空文字の場合は無効であること" do
      contact = build(:contact, email: "")
      expect(contact).to_not be_valid
      expect(contact.errors[:email]).to include("は必須項目です")
    end

    it "メールアドレスが空白の場合は無効であること" do
      contact = build(:contact, email: " ")
      expect(contact).to_not be_valid
      expect(contact.errors[:email]).to include("は必須項目です")
    end

    it "メールアドレスが31文字以上の場合は無効であること" do
      contact = build(:contact, email: "tester1234567890mail@example.com")
      expect(contact).to_not be_valid
      expect(contact.errors[:email]).to include("は30文字以内で入力してください")
    end

    it "不適切なメールアドレスのフォーマットが入力された場合は無効であること" do
      invalid_emails = ["tester", "tester@", "tester.com", "@example.com"]
      invalid_emails.each do |email|
        contact.email = email
        expect(contact).not_to be_valid
        expect(contact.errors[:email]).to include("は不正な値です")
      end
    end

    it "お問い合わせ内容がない場合は無効であること" do
      contact = build(:contact, content: nil)
      expect(contact).to_not be_valid
      expect(contact.errors[:content]).to include("は必須項目です")
    end

    it "お問い合わせ内容が空文字の場合は無効であること" do
      contact = build(:contact, content: "")
      expect(contact).to_not be_valid
      expect(contact.errors[:content]).to include("は必須項目です")
    end

    it "お問い合わせ内容が空白の場合は無効であること" do
      contact = build(:contact, content: " ")
      expect(contact).to_not be_valid
      expect(contact.errors[:content]).to include("は必須項目です")
    end

    it "お問い合わせ内容が801文字以上の場合は無効であること" do
      contact = build(:contact, content: "お問い合わせ内容です" * 80 + "。")
      expect(contact).to_not be_valid
      expect(contact.errors[:content]).to include("は800文字以内で入力してください")
    end
  end
end
