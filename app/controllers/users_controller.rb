class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
  end

  def show
    @user = current_user
  end

  def edit_password
    @user = current_user
    @minimum_password_length = Devise.password_length.min
  end

  def update_password
    @user = current_user
    @minimum_password_length = Devise.password_length.min
    if @user.update_with_password(user_params)
      sign_out @user
      flash[:notice] = "パスワードが更新されました。ログアウトしました。"
      redirect_to root_path
    else
      render "edit_password"
    end
  end

  def confirm_withdrawal
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
