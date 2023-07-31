class ProfilesController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_without_current_password(user_params)
      redirect_to user_path(@user)
    else
      render "edit"
    end
  end

  def delete_icon
    @user = current_user
    @user.icon.purge if @user.icon.attached?
    redirect_to edit_profile_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:username, :icon, :introduction, member_ids: [])
  end
end
