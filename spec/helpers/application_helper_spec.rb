require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#full_title" do
    subject { full_title(title) }

    context "引数が渡されている時" do
      let(:title) { "test" }

      it "「test | OSHIDOKO - 日向坂46の聖地マップ」と表示されること" do
        expect(subject).to eq("test | OSHIDOKO - 日向坂46の聖地マップ")
      end
    end

    context "引数が空白の時" do
      let(:title) { " " }

      it "「OSHIDOKO - 日向坂46の聖地マップ」と表示されること" do
        expect(subject).to eq("OSHIDOKO - 日向坂46の聖地マップ")
      end
    end

    context "引数が空文字の時" do
      let(:title) { "" }

      it "「OSHIDOKO - 日向坂46の聖地マップ」と表示されること" do
        expect(subject).to eq("OSHIDOKO - 日向坂46の聖地マップ")
      end
    end

    context "引数がnilの時" do
      let(:title) { nil }

      it "「OSHIDOKO - 日向坂46の聖地マップ」と表示されること" do
        expect(subject).to eq("OSHIDOKO - 日向坂46の聖地マップ")
      end
    end
  end
end
