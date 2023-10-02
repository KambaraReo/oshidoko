require 'rails_helper'

RSpec.describe PostsMember, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:member) }
  end
end
