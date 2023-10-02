require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:member) { create(:member) }

  describe "validations" do
    it "名前, 世代, 卒業有無が有効な状態であること" do
      expect(member).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users_members) }
    it { is_expected.to have_many(:users).through(:users_members) }
    it { is_expected.to have_many(:posts_members) }
    it { is_expected.to have_many(:posts).through(:posts_members) }
  end
end
