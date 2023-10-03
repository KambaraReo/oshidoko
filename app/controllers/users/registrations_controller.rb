class Users::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_normal_user, only: [:update, :destroy]

  protected

  # パスワードの変更以外で現在のパスワード入力を不要にする
  def update_resource(resource, params)
    resource.update_without_current_password(params)
  end

  # メールアドレス編集後のリダイレクト先
  def after_update_path_for(resource)
    mypage_users_path
  end

  # ゲストユーザーのアカウント更新・削除を不可にする
  def ensure_normal_user
    if resource.email == "guest@example.com"
      if params[:_method] == "delete"
        redirect_to mypage_users_path, alert: "ゲストユーザーは退会できません。"
      else
        redirect_to mypage_users_path, alert: "ゲストユーザーは更新できません。"
      end
    end
  end
end
