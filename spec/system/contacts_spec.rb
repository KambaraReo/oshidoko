require 'rails_helper'

RSpec.describe "contacts", type: :system do
  describe "お問い合わせ" do
    let(:contact) { create(:contact) }

    before do
      visit new_contact_path
    end

    describe "バリデーション成功" do
      context "確認ページに遷移した後, 送信ボタンをクリックした場合" do
        before do
          fill_in "contact[name]", with: contact.name
          fill_in "contact[email]", with: contact.email
          fill_in "contact[content]", with: contact.content

          click_on "入力内容の確認"
        end

        it "確認ページに遷移すること" do
          expect(page).to have_current_path confirm_contacts_path
        end

        it "確認ページに入力した内容が表示されていること" do
          within ".contact-form" do
            expect(page).to have_content contact.name
            expect(page).to have_content contact.email
            expect(page).to have_content contact.content
          end
        end

        it "送信ボタンをクリックすると完了ページに遷移し, 送信が完了した旨の表示がされること" do
          # メール送信をスタブ化
          allow(ContactMailer).to receive(:contact_mail).and_return(double(deliver_now: true))

          ContactMailer.contact_mail(contact)
          # メール送信が呼び出されたか検証
          expect(ContactMailer).to have_received(:contact_mail).with(contact)

          click_on "送信する"
          within ".contact-form" do
            expect(page).to have_content "送信しました。"
            expect(page).to have_content "お問い合わせありがとうございます。"
            expect(page).to have_link "TOPに戻る"
          end
        end
      end

      context "確認ページに遷移した後, 戻るボタンをクリックした場合" do
        before do
          fill_in "contact[name]", with: contact.name
          fill_in "contact[email]", with: contact.email
          fill_in "contact[content]", with: contact.content

          click_on "入力内容の確認"

          click_on "入力画面に戻る"
        end

        it "入力ページに遷移すること" do
          expect(page).to have_current_path back_contacts_path
        end

        it "入力フィールドにおいて一度入力した値が入力されている状態であること" do
          expect(find_field("contact[name]").value).to eq contact.name
          expect(find_field("contact[email]").value).to eq contact.email
          expect(find_field("contact[content]").value).to eq contact.content
        end
      end
    end

    describe "バリデーション失敗" do
      it "お名前, メールアドレス, お問い合わせ内容がnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: nil
        fill_in "contact[email]", with: nil
        fill_in "contact[content]", with: nil

        click_on "入力内容の確認"

        expect(page).to have_content "お名前は必須項目です"
        expect(page).to have_content "メールアドレスは必須項目です"
        expect(page).to have_content "お問い合わせ内容は必須項目です"
      end

      it "お名前, メールアドレス, お問い合わせ内容が空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: ""
        fill_in "contact[email]", with: ""
        fill_in "contact[content]", with: ""

        click_on "入力内容の確認"

        expect(page).to have_content "お名前は必須項目です"
        expect(page).to have_content "メールアドレスは必須項目です"
        expect(page).to have_content "お問い合わせ内容は必須項目です"
      end

      it "お名前, メールアドレス, お問い合わせ内容が空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: " "
        fill_in "contact[email]", with: " "
        fill_in "contact[content]", with: " "

        click_on "入力内容の確認"

        expect(page).to have_content "お名前は必須項目です"
        expect(page).to have_content "メールアドレスは必須項目です"
        expect(page).to have_content "お問い合わせ内容は必須項目です"
      end

      it "お名前が21文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: "a" * 21
        fill_in "contact[email]", with: contact.email
        fill_in "contact[content]", with: contact.content

        click_on "入力内容の確認"

        expect(page).to have_content "お名前は20文字以内で入力してください"
      end

      it "メールアドレスが31文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: contact.name
        fill_in "contact[email]", with: "a" * 20 + "@" + "example.com"
        fill_in "contact[content]", with: contact.content

        click_on "入力内容の確認"

        expect(page).to have_content "メールアドレスは30文字以内で入力してください"
      end

      it "メールアドレスが適切なフォーマットで入力されていない時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: contact.name
        fill_in "contact[email]", with: "a" * 10 + "@" + "examplecom"
        fill_in "contact[content]", with: contact.content

        click_on "入力内容の確認"

        expect(page).to have_content "メールアドレスは不正な値です"
      end

      it "お問い合わせ内容が801文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "contact[name]", with: contact.name
        fill_in "contact[email]", with: contact.email
        fill_in "contact[content]", with: "a" * 801

        click_on "入力内容の確認"

        expect(page).to have_content "お問い合わせ内容は800文字以内で入力してください"
      end
    end
  end
end
