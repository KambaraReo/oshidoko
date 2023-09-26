RSpec.shared_examples "header" do
  it "ロゴが適切なサイズで表示されていること" do
    within ".header-left" do
      expect(page).to have_selector "img[src*='OSHIDOKO'][width='150'][height='45']"
    end
  end

  it "ロゴをクリックした時, トップページに遷移すること" do
    within ".header-left" do
      find("img[src*='OSHIDOKO']").click
    end
    expect(page).to have_current_path root_path
  end

  it "TOPリンク, MAPリンク, POSTSリンク, CONTACTリンクが表示されていること" do
    within ".navbar" do
      expect(page).to have_link "TOP"
      expect(page).to have_link "MAP"
      expect(page).to have_link "POSTS"
      expect(page).to have_link "CONTACT"
    end
  end

  it "TOPリンクをクリックした時, トップページに遷移すること" do
    within ".navbar" do
      click_link "TOP"
    end
    expect(page).to have_current_path root_path
  end

  it "MAPリンクをクリックした時, MAP表示エリアに遷移すること" do
    within ".navbar" do
      click_link "MAP"
    end
    expect(page).to have_css "#map-anchor", visible: false
  end

  it "POSTSリンクをクリックした時, POSTS表示エリアに遷移すること" do
    within ".navbar" do
      click_link "POSTS"
    end
    expect(page).to have_css "#posts-anchor", visible: false
  end

  it "CONTACTリンクをクリックした時, お問い合わせページに遷移すること" do
    within ".navbar" do
      click_link "CONTACT"
    end
    expect(page).to have_current_path new_contact_path
  end

  describe "ログイン前" do
    it "ログインリンク, 新規登録リンクが表示されていること" do
      within ".navbar" do
        expect(page).to have_link "ログイン"
        expect(page).to have_link "新規登録"
      end
    end

    it "ログインリンクをクリックした時, ログインページに遷移すること" do
      within ".navbar" do
        click_link "ログイン"
      end
      expect(page).to have_current_path new_user_session_path
    end

    it "新規登録リンクをクリックした時, ユーザー登録ページに遷移すること" do
      within ".navbar" do
        click_link "新規登録"
      end
      expect(page).to have_current_path new_user_registration_path
    end
  end

  describe "ログイン後" do
    before do
      login(user)
      visit root_path
    end

    it "ログインリンク, 新規登録リンクが表示されていないこと" do
      within ".navbar" do
        expect(page).to_not have_link "ログイン"
        expect(page).to_not have_link "新規登録"
      end
    end

    it "ユーザー名が表示されていること" do
      within ".navbar" do
        expect(page).to have_link user.username
      end
    end

    it "ユーザー名をクリックした時, マイページに遷移すること" do
      within ".navbar" do
        click_link user.username
      end
      expect(page).to have_current_path mypage_users_path
    end

    describe "ユーザーアイコン" do
      context "アイコンが設定されていない場合" do
        it "デフォルトアイコンが適切に表示されていること" do
          within ".navbar" do
            expect(page).to have_selector "img[src*='default_user'][width='40'][height='40']"
          end
        end

        it "デフォルトアイコンをクリックした時, マイページに遷移すること" do
          within ".navbar" do
            find("img[src*='default_user']").click
          end
          expect(page).to have_current_path mypage_users_path
        end
      end

      context "アイコンが設定されている場合" do
        let(:user) { create(:user, :with_icon) }

        it "アイコンが適切に表示されていること" do
          within ".navbar" do
            expect(page).to have_selector "img[src*='#{user.icon.filename}'][width='40'][height='40']"
          end
        end

        it "アイコンをクリックした時, マイページに遷移すること" do
          within ".navbar" do
            find("img[src*='#{user.icon.filename}']").click
          end
          expect(page).to have_current_path mypage_users_path
        end
      end
    end
  end
end
