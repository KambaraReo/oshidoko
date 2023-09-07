require 'rails_helper'

RSpec.describe CommentsHelper, type: :helper do
  describe "#get_percent" do
    subject { get_percent(number) }

    context "引数が整数の時" do
      let(:number) { 5 }

      it "戻り値が文字列の「100」になること" do
        expect(subject).to eq("100")
      end
    end

    context "引数が小数の時" do
      let(:number) { 2.73 }

      it "戻り値が文字列の「55」になること" do
        expect(subject).to eq("55")
      end
    end

    context "引数が空の時" do
      let(:number) { "" }

      it "戻り値が「0」になること" do
        expect(subject).to eq(0)
      end
    end

    context "引数がnilの時" do
      let(:number) { nil }

      it "戻り値が「0」になること" do
        expect(subject).to eq(0)
      end
    end
  end
end
