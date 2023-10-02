module Login
  def login(user)
    user.confirm
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: user.password
    within ".actions" do
      click_on "ログイン"
    end
  end
end
