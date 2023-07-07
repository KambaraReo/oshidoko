class ApplicationController < ActionController::Base
  # deviseコントローラーにストロングパラメータを追加
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # ユーザー登録時にusernameのストロングパラメータを追加
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
