class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # パスワードの変更以外で現在のパスワード入力を不要にする
  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

  # メールアドレス編集後のリダイレクト先
  def after_update_path_for(resource)
    user_path(current_user)
  end
end
