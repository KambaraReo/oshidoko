module Logout
  def logout(user)
    visit mypage_users_path
    all(".link-field")[3].click
  end
end
