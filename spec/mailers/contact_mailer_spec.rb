require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  describe "#contact_mail" do
    let(:contact) { create(:contact) }

    subject(:mail) do
      described_class.contact_mail(contact).deliver_now
      ActionMailer::Base.deliveries.last
    end

    context "contact_mailが実行された時" do
      it "ヘッダーに件名と宛先が含まれていること" do
        expect(mail.subject).to eq("お問い合わせについて【自動送信】")
        expect(mail.to).to eq([contact.email])
        expect(mail.bcc).to eq([ENV['SEND_MAIL']])
      end

      it "本文に名前とお問い合わせ内容が含まれていること" do
        expect(mail.body).to match(contact.name)
        expect(mail.body).to match(contact.content)
      end
    end
  end
end
