require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "validations" do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: create(:user, email: "other_tester@example.com")) }
    let(:comment) { create(:comment, post_id: post.id, user_id: user.id) }

    it "コメント, 評価, ユーザーID, 投稿IDが有効な状態であること" do
      expect(comment).to be_valid
    end

    it "コメントが201文字以上の場合は無効であること" do
      comment = build(:comment, comment: "コメント" * 50 + "。")
      expect(comment).to_not be_valid
      expect(comment.errors[:comment]).to include("は200文字以内で入力してください")
    end

    it "評価がない場合は無効であること" do
      comment = build(:comment, rate: nil)
      expect(comment).to_not be_valid
      expect(comment.errors[:rate]).to include("を選択してください")
    end

    it "評価が空文字の場合は無効であること" do
      comment = build(:comment, rate: "")
      expect(comment).to_not be_valid
      expect(comment.errors[:rate]).to include("を選択してください")
    end

    it "評価が空白の場合は無効であること" do
      comment = build(:comment, rate: " ")
      expect(comment).to_not be_valid
      expect(comment.errors[:rate]).to include("を選択してください")
    end

    it "投稿に対する自分のコメントが既に存在している場合は無効であること" do
      other_comment = build(:comment, post_id: post.id, user_id: user.id)

      expect(comment).to be_valid
      expect(other_comment).to_not be_valid
      expect(other_comment.errors[:user_id]).to include("は既にレビューしています")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:post) }
  end
end
