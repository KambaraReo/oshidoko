require 'rails_helper'

RSpec.describe "users", type: :system, js: true do
  describe "ユーザー登録ページ" do
    let(:user) { build(:user) }

    before do
      visit new_user_registration_path
    end

    describe "バリデーション成功" do
      it "確認メールが送られ, アカウントを有効化すると, メールアドレスを確認した旨の表示がされること" do
        fill_in "user[username]", with: user.username
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password

        click_on "アカウントを作成"

        expect(page).to have_content "本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。"

        # 確認メールの送信を確認
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq "メールアドレス確認のご連絡"
        expect(last_email.to).to eq [user.email]

        # メール内の確認リンクをクリック
        confirmation_link = last_email.body.to_s.match(/href="(.+?)"/)[1].scan(/\/users\/confirmation\?confirmation_token=[^"]+/)[0]
        visit confirmation_link

        # ユーザーがアカウントを有効化したことを確認
        expect(page).to have_content "メールアドレスが確認できました。"
      end
    end

    describe "バリデーション失敗" do
      it "ユーザー名, メールアドレス, パスワードがnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: nil
        fill_in "user[email]", with: nil
        fill_in "user[password]", with: nil

        click_on "アカウントを作成"

        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "メールアドレスを入力してください"
        expect(page).to have_content "パスワードを入力してください"
      end

      it "ユーザー名, メールアドレス, パスワードが空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: ""
        fill_in "user[email]", with: ""
        fill_in "user[password]", with: ""

        click_on "アカウントを作成"

        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "メールアドレスを入力してください"
        expect(page).to have_content "パスワードを入力してください"
      end

      it "ユーザー名, メールアドレス, パスワードが空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: " "
        fill_in "user[email]", with: " "
        fill_in "user[password]", with: " "

        click_on "アカウントを作成"

        expect(page).to have_content "ユーザー名を入力してください"
        expect(page).to have_content "メールアドレスを入力してください"
        expect(page).to have_content "パスワードを入力してください"
      end

      it "ユーザー名が16文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: "a" * 16
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password

        click_on "アカウントを作成"

        expect(page).to have_content "ユーザー名は15文字以内で入力してください"
      end

      it "メールアドレスが適切なフォーマットで入力されていない時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: user.username
        fill_in "user[email]", with: "tester_1@example"
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password

        click_on "アカウントを作成"

        expect(page).to have_content "メールアドレスは不正な値です"
      end

      it "既に登録されているメールアドレスが入力された時, 適切なエラーメッセージが表示されること" do
        user = create(:user)

        fill_in "user[username]", with: user.username
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password

        click_on "アカウントを作成"

        expect(page).to have_content "メールアドレスはすでに存在します"
      end

      it "パスワードが5文字以下の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: user.username
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "pass"
        fill_in "user[password_confirmation]", with: "pass"

        click_on "アカウントを作成"

        expect(page).to have_content "パスワードは6文字以上で入力してください"
      end

      it "パスワードが21文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: user.username
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "a" * 21
        fill_in "user[password_confirmation]", with: "a" * 21

        click_on "アカウントを作成"

        expect(page).to have_content "パスワードは20文字以内で入力してください"
      end

      it "パスワードと確認パスワードが一致しない時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: user.username
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: "pass"

        click_on "アカウントを作成"

        expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
      end
    end

    describe "リンク" do
      it "ログインはこちらからをクリックした時, ログインページに遷移すること" do
        click_link "ログインはこちらから"
        expect(page).to have_current_path new_user_session_path
      end

      it "確認メールが届かない場合をクリックした時, 確認メール再送案内ページに遷移すること" do
        click_link "確認メールが届かない場合"
        expect(page).to have_current_path new_user_confirmation_path
      end
    end

    describe "パスワード表示/非表示切り替え機能の確認" do
      before do
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password
      end

      it "目のアイコンをクリックすると, パスワードが表示されること" do
        within "#password-toggle" do
          find("svg[data-icon='eye']").click
        end
        expect(page).to have_selector "input[type='text']#user_password"

        within "#password-confirmation-toggle" do
          find("svg[data-icon='eye']").click
        end
        expect(page).to have_selector "input[type='text']#user_password_confirmation"
      end

      it "スラッシュ目のアイコンをクリックすると, パスワードが表示されること" do
        within "#password-toggle" do
          find("svg[data-icon='eye']").click
          find("svg[data-icon='eye-slash']").click
        end
        expect(page).to have_selector "input[type='password']#user_password"

        within "#password-confirmation-toggle" do
          find("svg[data-icon='eye']").click
          find("svg[data-icon='eye-slash']").click
        end
        expect(page).to have_selector "input[type='password']#user_password_confirmation"
      end
    end
  end

  describe "ログインページ" do
    let(:user) { create(:user) }

    before do
      user.confirm
      visit new_user_session_path
    end

    describe "ログイン成功" do
      it "トップページに遷移し, ログインした旨の表示がされること" do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: user.password

        within ".log-in-form" do
          click_on "ログイン"
        end

        expect(page).to have_current_path root_path

        within ".notice" do
          expect(page).to have_content "ログインしました。"
        end
      end
    end

    describe "ログイン失敗" do
      it "メールアドレス, パスワードがnilの時, 適切なアラートが表示されること" do
        fill_in "user[email]", with: nil
        fill_in "user[password]", with: nil

        within ".log-in-form" do
          click_on "ログイン"
        end

        within ".alert" do
          expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        end
      end

      it "メールアドレス, パスワードが空文字の時, 適切なアラートが表示されること" do
        fill_in "user[email]", with: ""
        fill_in "user[password]", with: ""

        within ".log-in-form" do
          click_on "ログイン"
        end

        within ".alert" do
          expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        end
      end

      it "メールアドレス, パスワードが空白の時, 適切なアラートが表示されること" do
        fill_in "user[email]", with: " "
        fill_in "user[password]", with: " "

        within ".log-in-form" do
          click_on "ログイン"
        end

        within ".alert" do
          expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        end
      end

      it "誤ったメールアドレスが入力された時, 適切なアラートが表示されること" do
        fill_in "user[email]", with: "Tester_1@example.com"
        fill_in "user[password]", with: user.password

        within ".log-in-form" do
          click_on "ログイン"
        end

        within ".alert" do
          expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        end
      end

      it "誤ったパスワードが入力された時, 適切なアラートが表示されること" do
        fill_in "user[email]", with: user.email
        fill_in "user[password]", with: "passward123"

        within ".log-in-form" do
          click_on "ログイン"
        end

        within ".alert" do
          expect(page).to have_content "メールアドレスまたはパスワードが違います。"
        end
      end
    end

    it "ログインを記憶するを選択した時, remember_created_atがnilではないこと" do
      fill_in "user[email]", with: user.email
      fill_in "user[password]", with: user.password
      check "ログインを記憶する"

      within ".log-in-form" do
        click_on "ログイン"
      end

      user.reload
      expect(user.remember_created_at).to_not be_nil
    end

    describe "リンク" do
      it "ゲストログインをクリックした時, ゲスト用アカウントでログインされ, トップページに遷移すること" do
        click_link "ゲストログイン"
        expect(page).to have_current_path root_path

        within ".notice" do
          expect(page).to have_content "ゲストユーザーとしてログインしました。"
        end
        within ".header" do
          expect(page).to have_content "ゲスト"
        end
      end

      it "新規登録はこちらからをクリックした時, ユーザー登録ページに遷移すること" do
        click_link "新規登録はこちらから"
        expect(page).to have_current_path new_user_registration_path
      end

      it "パスワードをお忘れの方をクリックした時, パスワード再設定案内ページに遷移すること" do
        click_link "パスワードをお忘れの方"
        expect(page).to have_current_path new_user_password_path
      end
    end

    describe "パスワード表示/非表示切り替え機能の確認" do
      before do
        fill_in "user[password]", with: user.password
      end

      it "目のアイコンをクリックすると, パスワードが表示されること" do
        within "#password-toggle" do
          find("svg[data-icon='eye']").click
        end
        expect(page).to have_selector "input[type='text']#user_password"
      end

      it "スラッシュ目のアイコンをクリックすると, パスワードが表示されること" do
        within "#password-toggle" do
          find("svg[data-icon='eye']").click
          find("svg[data-icon='eye-slash']").click
        end
        expect(page).to have_selector "input[type='password']#user_password"
      end
    end
  end

  describe "確認メール再送案内ページ" do
    before do
      visit new_user_confirmation_path
    end

    describe "バリデーション成功" do
      let!(:user) { create(:user) }

      it "確認メールが再送され, アカウントを有効化すると, メールアドレスを確認した旨の表示がされること" do
        fill_in "user[email]", with: user.email

        click_on "送信する"

        within ".notice" do
          expect(page).to have_content "アカウントの有効化について数分以内にメールでご連絡します。"
        end

        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq "メールアドレス確認のご連絡"
        expect(last_email.to).to eq [user.email]

        confirmation_link = last_email.body.to_s.match(/href="(.+?)"/)[1].scan(/\/users\/confirmation\?confirmation_token=[^"]+/)[0]
        visit confirmation_link

        expect(page).to have_content "メールアドレスが確認できました。"
      end
    end

    describe "バリデーション失敗" do
      let!(:user) { create(:user) }

      it "メールアドレスがnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: nil

        click_on "送信する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: ""

        click_on "送信する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: " "

        click_on "送信する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "ユーザー登録されていないメールアドレスが入力された時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: "Tester_1@example.com"

        click_on "送信する"

        expect(page).to have_content "メールアドレスは見つかりませんでした。"
      end

      it "アカウント有効化済みのメールアドレスが入力された時, 適切なエラーメッセージが表示されること" do
        user.confirm

        fill_in "user[email]", with: user.email

        click_on "送信する"

        expect(page).to have_content "メールアドレスは既に登録済みです。ログインしてください。"
      end
    end

    describe "リンク" do
      it "ログインはこちらからをクリックした時, ログインページに遷移すること" do
        click_link "ログインはこちらから"
        expect(page).to have_current_path new_user_session_path
      end

      it "新規登録はこちらからをクリックした時, ユーザー登録ページに遷移すること" do
        click_link "新規登録はこちらから"
        expect(page).to have_current_path new_user_registration_path
      end

      it "パスワードをお忘れの方をクリックした時, パスワード再設定案内ページに遷移すること" do
        click_link "パスワードをお忘れの方"
        expect(page).to have_current_path new_user_password_path
      end
    end
  end

  describe "パスワード再設定案内ページ" do
    before do
      visit new_user_password_path
    end

    describe "バリデーション成功" do
      let!(:user) { create(:user) }

      before do
        fill_in "user[email]", with: user.email
        click_on "送信する"
      end

      it "パスワード再設定案内メールが送信された旨の表示がされること" do
        within ".notice" do
          expect(page).to have_content "パスワードの再設定について数分以内にメールでご連絡いたします。"
        end
      end

      it "メールに記載されたパスワード再設定用URLをクリックすると, パスワード再設定ページに遷移すること" do
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq "パスワード再設定のご案内"
        expect(last_email.to).to eq [user.email]

        reset_link = last_email.body.to_s.match(/href="(.+?)"/)[1].scan(/\/users\/password\/edit\?reset_password_token=[^"]+/)[0]
        visit reset_link

        expect(page).to have_current_path reset_link
        expect(page).to have_content "パスワード再設定"
        expect(page).to have_content "新しいパスワードを設定してください。"
      end

      describe "パスワード再設定" do
        before do
          last_email = ActionMailer::Base.deliveries.last

          reset_link = last_email.body.to_s.match(/href="(.+?)"/)[1].scan(/\/users\/password\/edit\?reset_password_token=[^"]+/)[0]
          visit reset_link
        end

        context "バリデーション成功" do
          before do
            fill_in "user[password]", with: "new_password123"
            fill_in "user[password_confirmation]", with: "new_password123"
            click_on "パスワードを再設定"
          end

          it "ログインページに遷移し, パスワードが変更された旨の通知が表示されること" do
            expect(page).to have_current_path new_user_session_path
            within ".notice" do
              expect(page).to have_content "パスワードが正しく変更されました。"
            end
          end
        end

        context "バリデーション失敗" do
          it "パスワードがnilの時, 適切なエラーメッセージが表示されること" do
            fill_in "user[password]", with: nil

            click_on "パスワードを再設定"

            expect(page).to have_content "パスワードを入力してください"
          end

          it "パスワードが空文字の時, 適切なエラーメッセージが表示されること" do
            fill_in "user[password]", with: ""

            click_on "パスワードを再設定"

            expect(page).to have_content "パスワードを入力してください"
          end

          it "パスワードが空白の時, 適切なエラーメッセージが表示されること" do
            fill_in "user[password]", with: " "

            click_on "パスワードを再設定"

            expect(page).to have_content "パスワードを入力してください"
          end

          it "パスワードが5文字以下の時, 適切なエラーメッセージが表示されること" do
            fill_in "user[password]", with: "pass"

            click_on "パスワードを再設定"

            expect(page).to have_content "パスワードは6文字以上で入力してください"
          end

          it "パスワードが21文字以上の時, 適切なエラーメッセージが表示されること" do
            fill_in "user[password]", with: "a" * 21

            click_on "パスワードを再設定"

            expect(page).to have_content "パスワードは20文字以内で入力してください"
          end

          it "パスワードと確認パスワードが一致しない時, 適切なエラーメッセージが表示されること" do
            fill_in "user[password]", with: "new_password123"
            fill_in "user[password_confirmation]", with: "new_passward123"

            click_on "パスワードを再設定"

            expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
          end
        end

        describe "パスワード表示/非表示切り替え機能の確認" do
          before do
            fill_in "user[password]", with: "new_password123"
            fill_in "user[password_confirmation]", with: "new_password123"
          end

          it "目のアイコンをクリックすると, パスワードが表示されること" do
            within "#password-toggle" do
              find("svg[data-icon='eye']").click
            end
            expect(page).to have_selector "input[type='text']#user_password"

            within "#password-confirmation-toggle" do
              find("svg[data-icon='eye']").click
            end
            expect(page).to have_selector "input[type='text']#user_password_confirmation"
          end

          it "スラッシュ目のアイコンをクリックすると, パスワードが表示されること" do
            within "#password-toggle" do
              find("svg[data-icon='eye']").click
              find("svg[data-icon='eye-slash']").click
            end
            expect(page).to have_selector "input[type='password']#user_password"

            within "#password-confirmation-toggle" do
              find("svg[data-icon='eye']").click
              find("svg[data-icon='eye-slash']").click
            end
            expect(page).to have_selector "input[type='password']#user_password_confirmation"
          end
        end

        describe "リンク" do
          it "ログインはこちらからをクリックした時, ログインページに遷移すること" do
            click_link "ログインはこちらから"
            expect(page).to have_current_path new_user_session_path
          end

          it "新規登録はこちらからをクリックした時, ユーザー登録ページに遷移すること" do
            click_link "新規登録はこちらから"
            expect(page).to have_current_path new_user_registration_path
          end
        end
      end
    end

    describe "バリデーション失敗" do
      let!(:user) { create(:user) }

      it "メールアドレスがnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: nil

        click_on "送信する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: ""

        click_on "送信する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: " "

        click_on "送信する"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "ユーザー登録されていないメールアドレスが入力された時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: "Tester_1@example.com"

        click_on "送信する"

        expect(page).to have_content "メールアドレスは見つかりませんでした。"
      end
    end

    describe "ゲスト用アカウントのメールアドレスを入力した場合" do
      it "ログインページに遷移し, 適切なアラートが表示されること" do
        fill_in "user[email]", with: "guest@example.com"

        click_on "送信する"

        expect(page).to have_current_path new_user_session_path
        within ".alert" do
          expect(page).to have_content "ゲストユーザーのパスワード再設定はできません。"
        end
      end
    end

    describe "リンク" do
      it "ログインはこちらからをクリックした時, ログインページに遷移すること" do
        click_link "ログインはこちらから"
        expect(page).to have_current_path new_user_session_path
      end

      it "新規登録はこちらからをクリックした時, ユーザー登録ページに遷移すること" do
        click_link "新規登録はこちらから"
        expect(page).to have_current_path new_user_registration_path
      end
    end
  end

  describe "マイページ" do
    let(:user) { create(:user) }

    before do
      login(user)
      visit mypage_users_path
    end

    describe "表示" do
      describe "ユーザーアイコン" do
        context "ユーザーアイコンが設定されていない場合" do
          it "デフォルトアイコンが適切に表示されていること" do
            within ".profile-area" do
              expect(page).to have_selector "img[src*='default_user'][width='70'][height='70']"
            end
          end
        end

        context "ユーザーアイコンが設定されている場合" do
          let(:user) { create(:user, :with_icon) }

          it "設定したアイコンが適切に表示されていること" do
            within ".profile-area" do
              expect(page).to have_selector "img[src*='#{user.icon.filename}'][width='70'][height='70']"
            end
          end
        end
      end

      describe "ユーザー名" do
        it "ユーザー名が表示されていること" do
          within ".profile-area-username" do
            expect(page).to have_content user.username
          end
        end
      end

      describe "フォロー, フォロワー" do
        let(:other_user_1) { create(:user) }
        let(:other_user_2) { create(:user) }

        before do
          user.following_users << other_user_1
          user.following_users << other_user_2
          user.follower_users << other_user_2

          visit mypage_users_path
        end

        it "フォロー, フォロワーの人数が表示されていること" do
          within ".profile-area-ff" do
            expect(page).to have_content "#{user.following_users.count}フォロー"
            expect(page).to have_content "#{user.follower_users.count}フォロワー"
          end
        end
      end

      describe "自己紹介" do
        context "自己紹介が設定されていない場合" do
          it "自己紹介は表示されていないこと" do
            within ".profile-area-introduction" do
              expect(page).to have_content ""
            end
          end
        end

        context "自己紹介が設定されている場合" do
          let(:user) { create(:user, introduction: "this is a profile for test.") }

          it "自己紹介が表示されていること" do
            within ".profile-area-introduction" do
              expect(page).to have_content user.introduction
            end
          end
        end
      end

      describe "推しメン" do
        context "推しメンが設定されていない場合" do
          it "未設定と表示されていること" do
            within ".profile-area-oshi" do
              expect(page).to have_content "推しメン"
              expect(page).to have_content "未設定"
            end
          end
        end

        context "推しメンが設定されている場合" do
          before do
            user.members << create_list(:member, 5)
            visit mypage_users_path
          end

          it "設定した推しメンが表示されていること" do
            within ".profile-area-oshi" do
              expect(page).to have_content "推しメン"
              user.members.each do |member|
                expect(page).to have_content member.name
              end
            end
          end
        end
      end

      describe "メールアドレス" do
        it "メールアドレスが表示されていること" do
          within ".link-field-email" do
            expect(page).to have_content user.email
          end
        end
      end
    end

    describe "リンク" do
      it "フォローをクリックした時, フォローページに遷移すること" do
        within ".profile-area-ff" do
          click_link "#{user.following_users.count}フォロー"
        end

        expect(page).to have_current_path follows_user_path(user)
        expect(page).to have_content "フォロー"
      end

      it "フォロワーをクリックした時, フォロワーページに遷移すること" do
        within ".profile-area-ff" do
          click_link "#{user.follower_users.count}フォロワー"
        end

        expect(page).to have_current_path followers_user_path(user)
        expect(page).to have_content "フォロワー"
      end

      it "詳細をクリックした時, ユーザー詳細ページに遷移すること" do
        within ".profile-area-top" do
          click_link "詳細"
        end

        expect(page).to have_current_path user_path(user)
      end

      it "メールアドレスをクリックした時, メールアドレス変更ページに遷移すること" do
        all(".link-field")[0].click

        expect(page).to have_current_path edit_user_registration_path
        expect(page).to have_content "メールアドレス変更"
      end

      it "パスワードをクリックした時, パスワード変更ページに遷移すること" do
        all(".link-field")[1].click

        expect(page).to have_current_path edit_password_users_path
        expect(page).to have_content "パスワード変更"
      end

      it "退会をクリックした時, 退会ページに遷移すること" do
        all(".link-field")[2].click

        expect(page).to have_current_path confirm_withdrawal_users_path
        within ".withdrawal-content" do
          expect(page).to have_content "退会"
        end
      end

      it "ログアウトをクリックした時, ログアウトしてトップページに遷移すること" do
        all(".link-field")[3].click

        expect(page).to have_current_path root_path
        within ".notice" do
          expect(page).to have_content "ログアウトしました。"
        end
      end
    end
  end

  describe "メールアドレス変更ページ" do
    let(:user) { create(:user) }

    before do
      login(user)
      visit edit_user_registration_path
    end

    it "MY PAGEリンクをクリックした時, マイページに遷移すること" do
      find(".mypage-link").click

      expect(page).to have_current_path mypage_users_path
      within ".mypage-container" do
        expect(page).to have_content "MY PAGE"
      end
    end

    context "バリデーション成功" do
      it "更新をクリックすると, メールアドレスが変更されること" do
        fill_in "user[email]", with: "new_#{user.email}"
        click_on "更新"

        expect(page).to have_current_path mypage_users_path
        within ".notice" do
          expect(page).to have_content "アカウント情報を変更しました。"
        end
        within ".link-field-email" do
          expect(page).to have_content "new_#{user.email}"
        end
      end
    end

    context "バリデーション失敗" do
      it "メールアドレスがnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: nil
        click_on "更新"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: ""
        click_on "更新"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: " "
        click_on "更新"

        expect(page).to have_content "メールアドレスを入力してください"
      end

      it "メールアドレスが適切なフォーマットで入力されていない時, 適切なエラーメッセージが表示されること" do
        fill_in "user[email]", with: "tester_1@example"
        click_on "更新"

        expect(page).to have_content "メールアドレスは不正な値です"
      end
    end

    context "ゲスト用アカウントでログインしている場合" do
      let(:guest_user) { User.guest }

      before do
        logout(user)
        login(guest_user)
        # visit new_user_session_path
        # click_link "ゲストログイン"
        visit edit_user_registration_path
      end

      it "メールアドレスを変更できないこと" do
        fill_in "user[email]", with: "new_#{guest_user.email}"
        click_on "更新"

        expect(page).to have_current_path mypage_users_path
        within ".alert" do
          expect(page).to have_content "ゲストユーザーは更新できません。"
        end
        within ".link-field-email" do
          expect(page).to have_content guest_user.email
          expect(page).to_not have_content "new_#{guest_user.email}"
        end
      end
    end
  end

  describe "パスワード変更ページ" do
    let(:user) { create(:user) }

    before do
      login(user)
      visit edit_password_users_path
    end

    it "MY PAGEリンクをクリックした時, マイページに遷移すること" do
      find(".mypage-link").click

      expect(page).to have_current_path mypage_users_path
      within ".mypage-container" do
        expect(page).to have_content "MY PAGE"
      end
    end

    context "バリデーション成功" do
      it "更新をクリックすると, パスワードが変更されるとともにログアウトし, トップページに遷移すること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", with: "new_#{user.password}"
        fill_in "user[password_confirmation]", with: "new_#{user.password}"
        click_on "更新"

        expect(page).to have_current_path root_path
        within ".notice" do
          expect(page).to have_content "パスワードが更新されました。ログアウトしました。"
        end
        within ".navbar" do
          expect(page).to have_link "ログイン"
          expect(page).to have_link "新規登録"
        end
      end
    end

    context "バリデーション失敗" do
      it "現在のパスワードがnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: nil
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password
        click_on "更新"

        expect(page).to have_content "現在のパスワードを入力してください"
      end

      it "現在のパスワードが空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: ""
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password
        click_on "更新"

        expect(page).to have_content "現在のパスワードを入力してください"
      end

      it "現在のパスワードが空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: " "
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password
        click_on "更新"

        expect(page).to have_content "現在のパスワードを入力してください"
      end

      it "現在のパスワードが誤って入力された時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: "passward123"
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password
        click_on "更新"

        expect(page).to have_content "現在のパスワードは不正な値です"
      end

      it "新しいパスワードが5文字以下の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", with: "pass"
        fill_in "user[password_confirmation]", with: "pass"
        click_on "更新"

        expect(page).to have_content "パスワードは6文字以上で入力してください"
      end

      it "新しいパスワードが21文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", with: "a" * 21
        fill_in "user[password_confirmation]", with: "a" * 21
        click_on "更新"

        expect(page).to have_content "パスワードは20文字以内で入力してください"
      end

      it "新しいパスワードと新しいパスワード(確認)が一致しない時, 適切なエラーメッセージが表示されること" do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", with: "new_#{user.password}"
        fill_in "user[password_confirmation]", with: "neww_#{user.password}"
        click_on "更新"

        expect(page).to have_content "パスワード（確認用）とパスワードの入力が一致しません"
      end
    end

    context "ゲスト用アカウントでログインしている場合" do
      let(:guest_user) { User.guest }

      before do
        logout(user)
        login(guest_user)
        # visit new_user_session_path
        # click_link "ゲストログイン"
        visit edit_password_users_path
      end

      it "パスワードを変更できないこと" do
        fill_in "user[current_password]", with: guest_user.password
        fill_in "user[password]", with: "new_#{guest_user.password}"
        fill_in "user[password_confirmation]", with: "new_#{guest_user.password}"
        click_on "更新"

        expect(page).to have_current_path mypage_users_path
        within ".alert" do
          expect(page).to have_content "ゲストユーザーは更新できません。"
        end
      end
    end

    describe "パスワード表示/非表示切り替え機能の確認" do
      before do
        fill_in "user[current_password]", with: user.password
        fill_in "user[password]", with: user.password
        fill_in "user[password_confirmation]", with: user.password
      end

      it "目のアイコンをクリックすると, パスワードが表示されること" do
        within "#current-password-toggle" do
          find("svg[data-icon='eye']").click
        end
        expect(page).to have_selector "input[type='text']#user_current_password"

        within "#password-toggle" do
          find("svg[data-icon='eye']").click
        end
        expect(page).to have_selector "input[type='text']#user_password"

        within "#password-confirmation-toggle" do
          find("svg[data-icon='eye']").click
        end
        expect(page).to have_selector "input[type='text']#user_password_confirmation"
      end

      it "スラッシュ目のアイコンをクリックすると, パスワードが表示されること" do
        within "#current-password-toggle" do
          find("svg[data-icon='eye']").click
          find("svg[data-icon='eye-slash']").click
        end
        expect(page).to have_selector "input[type='password']#user_current_password"

        within "#password-toggle" do
          find("svg[data-icon='eye']").click
          find("svg[data-icon='eye-slash']").click
        end
        expect(page).to have_selector "input[type='password']#user_password"

        within "#password-confirmation-toggle" do
          find("svg[data-icon='eye']").click
          find("svg[data-icon='eye-slash']").click
        end
        expect(page).to have_selector "input[type='password']#user_password_confirmation"
      end
    end
  end

  describe "退会ページ" do
    let(:user) { create(:user) }
    let(:guest_user) { User.guest }

    before do
      login(user)
      visit confirm_withdrawal_users_path
    end

    context "MY PAGEをクリックした時" do
      it "マイページに遷移すること" do
        click_link "MY PAGE"

        expect(page).to have_current_path mypage_users_path
        within ".mypage-container" do
          expect(page).to have_content "MY PAGE"
        end
      end
    end

    context "退会をクリックした時" do
      it "アカウント削除に関する確認ダイアログが表示されること" do
        page.dismiss_confirm("本当に退会しますか？") do
          click_link "退会する"
        end
      end

      it "確認ダイアログにてキャンセルを選択した場合は退会ページに留まること" do
        page.dismiss_confirm("本当に退会しますか？") do
          click_link "退会する"
        end

        expect(page).to have_current_path confirm_withdrawal_users_path
      end

      it "確認ダイアログにてOKを選択した場合はアカウントが削除され, トップページに遷移すること" do
        page.accept_confirm("本当に退会しますか？") do
          click_link "退会する"
        end

        expect(page).to have_current_path root_path
        within ".notice" do
          expect(page).to have_content "退会処理が完了しました。"
        end
        within ".navbar" do
          expect(page).to have_link "ログイン"
          expect(page).to have_link "新規登録"
        end
      end

      it "ゲスト用アカウントでログインしている場合は退会できないこと" do
        logout(user)
        login(guest_user)
        visit confirm_withdrawal_users_path

        page.accept_confirm("本当に退会しますか？") do
          click_link "退会する"
        end

        expect(page).to have_current_path mypage_users_path
        within ".alert" do
          expect(page).to have_content "ゲストユーザーは退会できません。"
        end
      end
    end
  end

  describe "ユーザー詳細ページ" do
    let(:user) { create(:user) }
    let(:other_user_1) { create(:user, :with_icon, introduction: "this is a introduction for test.") }
    let(:other_user_2) { create(:user) }

    before do
      # ユーザーのフォロー関係を定義
      other_user_1.following_users << user
      other_user_1.following_users << other_user_2
      other_user_1.follower_users << other_user_2

      # ユーザーの投稿を定義
      other_user_1.posts << create_list(:post, 2)
      other_user_1.posts[0].update(created_at: 1.day.ago)
      other_user_1.posts[1].update(created_at: Time.now)
      user.posts << create_list(:post, 5)
      user.posts.each_with_index do |post, index|
        post.update(created_at: (5 - index).day.ago)
      end
      other_user_2.posts << create_list(:post, 3)
      other_user_2.posts.each_with_index do |post, index|
        post.update(created_at: (3 - index).day.ago)
      end

      # ユーザーの推しメンを定義
      other_user_1.members << create_list(:member, 5)

      # 投稿のいいねを定義
      other_user_2.posts[1].favorited_users << user
      user.posts[2].favorited_users << other_user_1
      user.posts[4].favorited_users << other_user_1
      other_user_2.posts[0].favorited_users << other_user_1
      other_user_2.posts[1].favorited_users << other_user_1

      login(user)
      visit user_path(other_user_1)
    end

    describe "ナビゲーションリンク" do
      it "TOPをクリックするとトップページに遷移すること" do
        within ".navigation-link" do
          click_link "TOP"
        end
        expect(page).to have_current_path root_path
      end

      it "ナビゲーションリンクにユーザー名が表示されていること" do
        within ".navigation-link" do
          expect(page).to have_content other_user_1.username
        end
      end
    end

    describe "profile" do
      it "ユーザーアイコンが表示されていること" do
        within ".profile-area-top" do
          expect(page).to have_selector "img[src*='#{other_user_1.icon.filename}'][width='70'][height='70']"
        end
      end

      it "ユーザー名が表示されていること" do
        within ".profile-area-username" do
          expect(page).to have_content other_user_1.username
        end
      end

      it "フォロー, フォロワーの人数が表示されていること" do
        within ".profile-area-ff" do
          expect(page).to have_content "#{other_user_1.following_users.count}フォロー"
          expect(page).to have_content "#{other_user_1.follower_users.count}フォロワー"
        end
      end

      it "自己紹介が表示されていること" do
        within ".profile-area-introduction" do
          expect(page).to have_content other_user_1.introduction
        end
      end

      it "設定した推しメンが表示されていること" do
        within ".profile-area-oshi" do
          expect(page).to have_content "推しメン"
          other_user_1.members.each do |member|
            expect(page).to have_content member.name
          end
        end
      end

      it "フォローボタンが適切な状態で表示されていること" do
        within ".profile-area-top" do
          expect(page).to have_css ".btn-follow"
          expect(page).to_not have_css ".btn-unfollow"
        end
      end

      it "フォローをクリックした時, フォローページに遷移すること" do
        within ".profile-area-ff" do
          click_link "#{other_user_1.following_users.count}フォロー"
        end

        expect(page).to have_current_path follows_user_path(other_user_1)
      end

      it "フォロワーをクリックした時, フォロワーページに遷移すること" do
        within ".profile-area-ff" do
          click_link "#{other_user_1.follower_users.count}フォロワー"
        end

        expect(page).to have_current_path followers_user_path(other_user_1)
      end

      it "未フォロー時にフォローボタンをクリックした場合, ボタンの表示がフォロー中になり, フォロワー数の表示が1増えること" do
        initial_count = other_user_1.follower_users.count
        expect(page).to have_content "#{initial_count}フォロワー"

        within ".profile-area-top" do
          find(".btn-follow").click
          expect(page).to have_css ".btn-unfollow"
          expect(page).to_not have_css ".btn-follow"
        end

        expect(other_user_1.follower_users.count).to eq initial_count + 1
        expect(page).to have_content "#{initial_count + 1}フォロワー"
      end

      it "フォロー済みでフォローボタンをクリックした場合, ボタンの表示がフォローになり, フォロワー数の表示が1減ること" do
        within ".profile-area-top" do
          find(".btn-follow").click
        end

        initial_count = other_user_1.follower_users.count
        expect(page).to have_content "#{initial_count}フォロワー"

        within ".profile-area-top" do
          find(".btn-unfollow").click
          expect(page).to have_css ".btn-follow"
          expect(page).to_not have_css ".btn-unfollow"
        end

        expect(other_user_1.follower_users.count).to eq initial_count - 1
        expect(page).to have_content "#{initial_count - 1}フォロワー"
      end

      context "ログインユーザーのユーザー詳細ページの場合" do
        before do
          visit user_path(user)
        end

        it "フォローボタンが表示されないこと" do
          within ".profile-area-top" do
            expect(page).to_not have_css ".btn-follow"
            expect(page).to_not have_css ".btn-unfollow"
          end
        end

        it "プロフィール編集リンクが表示されること" do
          within ".profile-area-top" do
            expect(page).to have_css ".link-field-profile"
          end
        end

        it "プロフィール編集リンクをクリックした時, プロフィール編集ページに遷移すること" do
          within ".profile-area-top" do
            find(".link-field-profile").click
          end

          expect(page).to have_current_path edit_profile_path
        end
      end

      context "未ログインの場合" do
        before do
          logout(user)
          visit user_path(other_user_1)
        end

        it "フォローボタンをクリックした時, ログインページに遷移し, 適切なメッセージが表示されること" do
          within ".profile-area-top" do
            find(".btn-follow").click
          end

          expect(page).to have_current_path new_user_session_path
          within ".alert" do
            expect(page).to have_content "ログインもしくはアカウント登録してください。"
          end
        end

        it "プロフィール編集リンクが表示されないこと" do
          within ".profile-area-top" do
            expect(page).to_not have_css ".link-field-profile"
          end
        end
      end
    end

    describe "my posts" do
      it "いいね一覧のリンクが表示されていること" do
        within ".posts-area" do
          expect(page).to have_link "いいね一覧"
        end
      end

      it "いいね一覧のリンクをクリックした時, いいねした投稿の一覧が表示されたユーザー詳細ページに遷移すること" do
        within ".posts-area" do
          click_link "いいね一覧"
        end

        expect(page).to have_current_path favorites_user_path(other_user_1)
      end

      it "投稿数が適切に表示されていること" do
        within ".number-of-displays" do
          expect(page).to have_content other_user_1.posts.count
        end
      end

      it "投稿が作成日の降順で表示されていること" do
        within ".posts" do
          post_dates = all(".post-created-at").map(&:text)

          expect(post_dates).to eq post_dates.sort.reverse
        end
      end

      it "参照しているユーザーの投稿のみが表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content post.user.username
            expect(page).to have_content post.title
          end
          user.posts.each do |post|
            expect(page).to_not have_content post.user.username
            expect(page).to_not have_content post.title
          end
          other_user_2.posts.each do |post|
            expect(page).to_not have_content post.user.username
            expect(page).to_not have_content post.title
          end
        end
      end

      it "ユーザーアイコンが表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_selector "img[src*='#{other_user_1.icon.filename}']"
          end
        end
      end

      it "ユーザー名が表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content post.user.username
          end
        end
      end

      it "投稿タイトルが表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content post.title
          end
        end
      end

      it "住所が表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content post.address
          end
        end
      end

      it "関連メンバーが表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content "関連メンバー"
            post.members.each do |member|
              expect(page).to have_content member.name
            end
          end
        end
      end

      it "投稿作成日が表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content post.created_at.strftime("%Y年%m月%d日 %H:%M")
          end
        end
      end

      it "詳細リンクのみ表示され, 編集リンク及び削除リンクは表示されないこと" do
        within ".posts" do
          user.posts.each do |post|
            expect(page).to have_css ".info-link"
            expect(page).to_not have_css ".edit-link"
            expect(page).to_not have_css ".delete-link"
          end
        end
      end

      it "いいね数が表示されていること" do
        within ".posts" do
          other_user_1.posts.each do |post|
            expect(page).to have_content post.favorites.count
          end
        end
      end

      it "ユーザー名をクリックした時, ユーザー詳細ページに遷移すること" do
        within ".posts" do
          all("a", text: other_user_1.posts[0].user.username)[0].click
        end
        expect(page).to have_current_path user_path(other_user_1.posts[1].user)
      end

      it "投稿タイトルをクリックした時, 投稿詳細ページに遷移すること" do
        within ".posts" do
          click_link other_user_1.posts[0].title
        end
        expect(page).to have_current_path post_path(other_user_1.posts[0])
      end

      it "詳細リンクをクリックした時, 投稿詳細ページに遷移すること" do
        within ".posts" do
          all(".info-link")[0].click
        end
        expect(page).to have_current_path post_path(other_user_1.posts[1])
      end

      it "未いいね状態でいいねアイコンをクリックした時, アイコンが変化するとともに, いいねの表示が1増えること" do
        within "#favorite-post-#{other_user_1.posts[0].id}" do
          initial_count = other_user_1.posts[0].favorites.count
          expect(page).to have_link "#{initial_count}"

          find(".heart").click
          expect(page).to have_css ".filled-heart"
          expect(page).to have_link "#{initial_count + 1}"
        end
      end

      it "いいね済み状態でいいねアイコンをクリックした時, アイコンが変化するとともに, いいねの表示が1減ること" do
        within "#favorite-post-#{other_user_1.posts[0].id}" do
          find(".heart").click
          expect(page).to have_css ".filled-heart"
          initial_count = other_user_1.posts[0].favorites.count
          expect(page).to have_link "#{initial_count}"

          find(".filled-heart").click
          expect(page).to have_css ".heart"
          expect(page).to have_link "#{initial_count - 1}"
        end
      end

      context "ログインユーザーのユーザー詳細ページの場合" do
        before do
          visit user_path(user)
        end

        it "詳細リンク, 編集リンク, 削除リンクが表示されていること" do
          within ".posts" do
            user.posts.each do |post|
              expect(page).to have_css ".info-link"
              expect(page).to have_css ".edit-link"
              expect(page).to have_css ".delete-link"
            end
          end
        end

        it "編集リンクをクリックした時, 投稿編集ページに遷移すること" do
          within ".posts" do
            all(".edit-link")[0].click
          end
          expect(page).to have_current_path edit_post_path(user.posts[4])
        end

        describe "削除リンクをクリックした時" do
          it "投稿削除に関する確認ダイアログが表示されること" do
            page.dismiss_confirm("投稿を削除しますか？") do
              within ".posts" do
                all(".delete-link")[0].click
              end
            end
          end

          it "確認ダイアログにてキャンセルを選択した場合はユーザー詳細ページに留まること" do
            page.dismiss_confirm("投稿を削除しますか？") do
              within ".posts" do
                all(".delete-link")[0].click
              end
            end

            expect(page).to have_current_path user_path(user)
          end

          it "確認ダイアログにてOKを選択した場合は投稿が削除され, 適切なメッセージが表示されること" do
            post_before_delete = user.posts[4].title

            page.accept_confirm("投稿を削除しますか？") do
              within ".posts" do
                all(".delete-link")[0].click
              end
            end

            within ".posts" do
              expect(page).to_not have_link post_before_delete
            end

            within ".notice" do
              expect(page).to have_content "投稿を削除しました。"
            end
          end
        end
      end

      context "未ログインの場合" do
        before do
          logout(user)
          visit user_path(other_user_1)
        end

        it "いいねボタンをクリックした時, ログインページに遷移し, 適切なメッセージが表示されること" do
          within "#favorite-post-#{other_user_1.posts[0].id}" do
            find(".heart").click
          end

          expect(page).to have_current_path new_user_session_path
          within ".alert" do
            expect(page).to have_content "ログインが必要です。"
          end
        end
      end
    end

    describe "my favorites" do
      before do
        visit favorites_user_path(other_user_1)
      end

      it "マイ投稿一覧のリンクが表示されていること" do
        within ".posts-area" do
          expect(page).to have_link "マイ投稿一覧"
        end
      end

      it "マイ投稿一覧のリンクをクリックした時, 参照ユーザーの投稿のみが表示されたユーザー詳細ページに遷移すること" do
        within ".posts-area" do
          click_link "マイ投稿一覧"
        end

        expect(page).to have_current_path user_path(other_user_1)
      end

      it "いいねしている投稿数が適切に表示されていること" do
        within ".number-of-displays" do
          expect(page).to have_content "4"
        end
      end

      it "投稿が作成日の降順で表示されていること" do
        within ".posts" do
          post_dates = all(".post-created-at").map(&:text)

          expect(post_dates).to eq post_dates.sort.reverse
        end
      end

      it "参照しているユーザーがいいねした投稿のみが表示されていること" do
        within ".posts" do
          expect(page).to_not have_content user.posts[0].title
          expect(page).to_not have_content user.posts[1].title
          expect(page).to have_content user.posts[2].title
          expect(page).to_not have_content user.posts[3].title
          expect(page).to have_content user.posts[4].title
          expect(page).to_not have_content other_user_1.posts[0].title
          expect(page).to_not have_content other_user_1.posts[1].title
          expect(page).to have_content other_user_2.posts[0].title
          expect(page).to have_content other_user_2.posts[1].title
          expect(page).to_not have_content other_user_2.posts[2].title
        end
      end

      it "参照ユーザーがいいねしている投稿に, ログインユーザーもいいねしている場合は, いいねアイコンがいいね済みの状態になって表示されていること" do
        within "#favorite-post-#{other_user_2.posts[1].id}" do
          expect(page).to have_css ".filled-heart"
        end
      end

      it "参照ユーザーがいいねしている投稿に, ログインユーザーの投稿が含まれている場合, ログインユーザーの投稿には編集リンク及び削除リンクが表示されていること" do
        within ".posts" do
          expect(page).to have_css(".info-link", count: 4)
          expect(page).to have_css(".edit-link", count: 2)
          expect(page).to have_css(".delete-link", count: 2)
        end
      end
    end
  end

  describe "プロフィール編集ページ" do
    let(:user) { create(:user) }
    let!(:members) { create_list(:member, 5) }

    before do
      login(user)
      visit edit_profile_path
    end

    describe "バリデーション成功" do
      it "ユーザー詳細ページに遷移し, プロフィールが更新された旨のメッセージが表示されるとともに, 更新された情報がプロフィールに表示されていること" do
        attach_file "user[icon]", "#{Rails.root}/spec/fixtures/512bytes_sample.png"
        fill_in "user[username]", with: "new_#{user.username}"
        fill_in "user[introduction]", with: "this is a introduction for test."
        check "user[member_ids][]", option: members[0].id
        check "user[member_ids][]", option: members[2].id
        check "user[member_ids][]", option: members[4].id

        click_on "更新"

        expect(page).to have_current_path user_path(user)

        within ".notice" do
          expect(page).to have_content "プロフィールを更新しました。"
        end

        within ".profile-area-top" do
          expect(page).to have_selector "img[src*='512bytes_sample']"
        end

        within ".profile-area-username" do
          expect(page).to have_content "new_#{user.username}"
        end

        within ".profile-area-introduction" do
          expect(page).to have_content "this is a introduction for test."
        end

        within ".profile-area-oshi" do
          expect(page).to have_content members[0].name
          expect(page).to_not have_content members[1].name
          expect(page).to have_content members[2].name
          expect(page).to_not have_content members[3].name
          expect(page).to have_content members[4].name
        end
      end

      describe "ユーザーアイコンの削除" do
        context "アイコンが設定されていない場合" do
          it "アイコンを削除のリンクが表示されていないこと" do
            within ".icon-line" do
              expect(page).to_not have_link "アイコンを削除"
            end
          end
        end

        context "アイコンが設定されている場合" do
          let(:user) { create(:user, :with_icon) }

          it "アイコンを削除のリンクが表示されていること" do
            within ".icon-line" do
              expect(page).to have_link "アイコンを削除"
            end
          end

          it "アイコンを削除をクリックすると, アイコン削除に関する確認ダイアログが表示されること" do
            page.dismiss_confirm("アイコンを削除しますか？") do
              click_link "アイコンを削除"
            end
          end

          it "確認ダイアログにてキャンセルを選択した場合はプロフィール編集ページに留まること" do
            page.dismiss_confirm("アイコンを削除しますか？") do
              click_link "アイコンを削除"
            end

            expect(page).to have_current_path edit_profile_path
          end

          it "確認ダイアログにてOKを選択した場合はアイコンが削除され, ユーザー詳細ページに遷移し, デフォルトアイコンが表示されること" do
            page.accept_confirm("アイコンを削除しますか？") do
              click_link "アイコンを削除"
            end

            expect(page).to have_current_path user_path(user)
            within ".notice" do
              expect(page).to have_content "アイコンを削除しました。"
            end
          end
        end
      end
    end

    describe "バリデーション失敗" do
      it "ユーザー名がnilの時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: nil

        click_on "更新"

        expect(page).to have_content "ユーザー名を入力してください"
      end

      it "ユーザー名が空文字の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: ""

        click_on "更新"

        expect(page).to have_content "ユーザー名を入力してください"
      end

      it "ユーザー名が空白の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: " "

        click_on "更新"

        expect(page).to have_content "ユーザー名を入力してください"
      end

      it "ユーザー名が16文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[username]", with: "a" * 16

        click_on "更新"

        expect(page).to have_content "ユーザー名は15文字以内で入力してください"
      end

      it "プロフィール(自己紹介)が201文字以上の時, 適切なエラーメッセージが表示されること" do
        fill_in "user[introduction]", with: "a" * 201

        click_on "更新"

        expect(page).to have_content "プロフィールは200文字以内で入力してください"
      end
    end

    it "キャンセルをクリックした時, ユーザー詳細ページに遷移すること" do
      click_link "キャンセル"

      expect(page).to have_current_path user_path(user)
    end
  end

  describe "フォローページ, フォロワーページ" do
    let(:user) { create(:user) }
    let(:other_user_1) { create(:user, :with_icon) }
    let(:other_user_2) { create(:user) }

    describe "フォロー, フォロワーがいる場合" do
      before do
        user.following_users << other_user_1
        user.following_users << other_user_2
        user.follower_users << other_user_2

        other_user_1.posts << create_list(:post, 2)
        other_user_2.posts << create_list(:post, 7)

        other_user_1.members << create_list(:member, 5)

        login(user)
      end

      describe "フォローページ" do
        before do
          visit follows_user_path(user)
        end

        describe "ユーザーリスト内の表示" do
          it "ユーザーアイコン, ユーザー名, 投稿数, 推しメンが表示されていること" do
            within ".content" do
              expect(page).to have_selector "img[src*='#{other_user_1.icon.filename}'][width='45'][height='45']"
              expect(page).to have_selector "img[src*='default_user'][width='45'][height='45']"
              expect(page).to have_content other_user_1.username
              expect(page).to have_content other_user_2.username
              expect(page).to have_content "投稿数 #{other_user_1.posts.count}"
              expect(page).to have_content "投稿数 #{other_user_2.posts.count}"
              other_user_1.members.each do |member|
                expect(page).to have_content member.name
              end
              expect(page).to have_content "未設定"
            end
          end

          it "フォローボタンがすべてフォロー中になっていること" do
            within ".content" do
              expect(page).to have_css ".btn-unfollow"
              expect(page).to_not have_css ".btn-follow"
            end

            elements = all(".btn-unfollow")
            expect(elements.count).to eq user.following_users.count
          end
        end

        describe "ユーザーリスト内のリンク" do
          it "ユーザーアイコンをクリックするとユーザー詳細ページに遷移すること" do
            within ".content" do
              find("img[src*='#{other_user_1.icon.filename}']").click
            end
            expect(page).to have_current_path user_path(other_user_1)
          end

          it "ユーザー名をクリックするとユーザー詳細ページに遷移すること" do
            within ".content" do
              click_link other_user_1.username
            end
            expect(page).to have_current_path user_path(other_user_1)
          end
        end

        describe "フォローボタン" do
          context "ログインユーザーのフォローページの場合" do
            it "フォロー中と表示されているボタンをクリックするとフォローが外れ, 該当ユーザーが表示されないこと" do
              within ".content" do
                all(".btn-unfollow")[0].click
                expect(page).to_not have_content other_user_1.username
                expect(page).to have_content other_user_2.username
              end
            end
          end

          context "他ユーザーのフォローページの場合" do
            before do
              other_user_1.following_users << user
              other_user_1.following_users << other_user_2

              visit follows_user_path(other_user_1)
            end

            it "フォロー中と表示されているボタンをクリックするとフォローが外れ, ボタンの表示がフォローになること" do
              initial_count = user.following_users.count

              within all(".user")[1] do
                within ".profile-area-top" do
                  find(".btn-unfollow").click
                end
              end

              within all(".user")[1] do
                within ".profile-area-top" do
                  expect(page).to have_css ".btn-follow"
                  expect(page).to_not have_css ".btn-unfollow"
                end
              end

              expect(user.following_users.count).to eq initial_count - 1
            end

            it "フォローと表示されているボタンをクリックするとフォローして, ボタンの表示がフォロー中になること" do
              within all(".user")[1] do
                within ".profile-area-top" do
                  find(".btn-unfollow").click
                end
              end

              initial_count = user.following_users.count

              within all(".user")[1] do
                within ".profile-area-top" do
                  find(".btn-follow").click
                end
              end

              within all(".user")[1] do
                within ".profile-area-top" do
                  expect(page).to have_css ".btn-unfollow"
                  expect(page).to_not have_css ".btn-follow"
                end
              end

              expect(user.following_users.count).to eq initial_count + 1
            end

            it "ログインユーザーと一致するユーザーのリストではフォローボタンが表示されないこと" do
              within all(".user")[0] do
                expect(page).to_not have_css ".btn-unfollow"
                expect(page).to_not have_css ".btn-follow"
              end
            end
          end
        end
      end

      describe "フォロワーページ" do
        before do
          visit followers_user_path(user)
        end

        describe "ユーザーリスト内の表示" do
          it "ユーザーアイコン, ユーザー名, 投稿数, 推しメンが表示されていること" do
            within ".content" do
              expect(page).to_not have_selector "img[src*='#{other_user_1.icon.filename}'][width='45'][height='45']"
              expect(page).to have_selector "img[src*='default_user'][width='45'][height='45']"
              expect(page).to_not have_content other_user_1.username
              expect(page).to have_content other_user_2.username
              expect(page).to_not have_content "投稿数 #{other_user_1.posts.count}"
              expect(page).to have_content "投稿数 #{other_user_2.posts.count}"
              other_user_1.members.each do |member|
                expect(page).to_not have_content member.name
              end
              expect(page).to have_content "未設定"
            end
          end

          it "フォローボタンが適切な状態で表示されていること" do
            within ".content" do
              expect(page).to have_css ".btn-unfollow"
              expect(page).to_not have_css ".btn-follow"
            end

            elements = all(".btn-unfollow")
            expect(elements.count).to eq user.follower_users.count
          end
        end

        describe "ユーザーリスト内のリンク" do
          it "ユーザーアイコンをクリックするとユーザー詳細ページに遷移すること" do
            within ".content" do
              find("img[src*='default_user']").click
            end
            expect(page).to have_current_path user_path(other_user_2)
          end

          it "ユーザー名をクリックするとユーザー詳細ページに遷移すること" do
            within ".content" do
              click_link other_user_2.username
            end
            expect(page).to have_current_path user_path(other_user_2)
          end
        end

        describe "フォローボタン" do
          before do
            other_user_2.follower_users << other_user_1

            visit followers_user_path(other_user_2)
          end

          it "フォロー中と表示されているボタンをクリックするとフォローが外れ, ボタンの表示がフォローになること" do
            initial_count = user.following_users.count

            within all(".user")[1] do
              within ".profile-area-top" do
                find(".btn-unfollow").click
              end
            end

            within all(".user")[1] do
              within ".profile-area-top" do
                expect(page).to have_css ".btn-follow"
                expect(page).to_not have_css ".btn-unfollow"
              end
            end

            expect(user.following_users.count).to eq initial_count - 1
          end

          it "フォローと表示されているボタンをクリックするとフォローして, ボタンの表示がフォロー中になること" do
            within all(".user")[1] do
              within ".profile-area-top" do
                find(".btn-unfollow").click
              end
            end

            initial_count = user.following_users.count

            within all(".user")[1] do
              within ".profile-area-top" do
                find(".btn-follow").click
              end
            end

            within all(".user")[1] do
              within ".profile-area-top" do
                expect(page).to have_css ".btn-unfollow"
                expect(page).to_not have_css ".btn-follow"
              end
            end

            expect(user.following_users.count).to eq initial_count + 1
          end

          it "ログインユーザーと一致するユーザーのリストではフォローボタンが表示されないこと" do
            within all(".user")[0] do
              expect(page).to_not have_css ".btn-unfollow"
              expect(page).to_not have_css ".btn-follow"
            end
          end
        end
      end
    end

    describe "フォロー, フォロワーがいない場合" do
      describe "フォローページ" do
        before do
          visit follows_user_path(user)
        end

        it "フォローしているユーザーがいない旨の表示がされていること" do
          within ".not-applicable" do
            expect(page).to have_content "フォローしたユーザーはいません。"
          end
        end
      end

      describe "フォロワーページ" do
        before do
          visit followers_user_path(user)
        end

        it "フォロワーがいない旨の表示がされていること" do
          within ".not-applicable" do
            expect(page).to have_content "フォロワーを獲得しましょう。"
          end
        end
      end
    end

    describe "ナビゲーションリンク" do
      describe "フォローページ" do
        before do
          visit follows_user_path(user)
        end

        it "TOPをクリックするとトップページに遷移すること" do
          within ".navigation-link" do
            click_link "TOP"
          end
          expect(page).to have_current_path root_path
        end

        it "ナビゲーションリンクにユーザー名が表示されていること" do
          within ".navigation-link" do
            expect(page).to have_content user.username
          end
        end

        it "ユーザー名をクリックするとユーザー詳細ページに遷移すること" do
          within ".navigation-link" do
            click_link user.username
          end
          expect(page).to have_current_path user_path(user)
        end
      end

      describe "フォロワーページ" do
        before do
          visit followers_user_path(user)
        end

        it "TOPをクリックするとトップページに遷移すること" do
          within ".navigation-link" do
            click_link "TOP"
          end
          expect(page).to have_current_path root_path
        end

        it "ナビゲーションリンクにユーザー名が表示されていること" do
          within ".navigation-link" do
            expect(page).to have_content user.username
          end
        end

        it "ユーザー名をクリックするとユーザー詳細ページに遷移すること" do
          within ".navigation-link" do
            click_link user.username
          end
          expect(page).to have_current_path user_path(user)
        end
      end
    end
  end
end
