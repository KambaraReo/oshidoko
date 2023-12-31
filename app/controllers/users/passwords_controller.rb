class Users::PasswordsController < Devise::PasswordsController
  before_action :ensure_normal_user, only: :create

  protected

  # パスワードリセット後のリダイレクト先
  def after_resetting_password_path_for(resource)
    new_user_session_path
  end

  # ゲストユーザーのパスワード再設定を不可にする
  def ensure_normal_user
    if params[:user][:email].downcase == "guest@example.com"
      redirect_to new_user_session_path, alert: "ゲストユーザーのパスワード再設定はできません。"
    end
  end
end
