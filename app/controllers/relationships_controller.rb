class RelationshipsController < ApplicationController
  before_action :authenticate_user!, except: [:create, :destroy]

  def create
    @user = current_user
    if user_signed_in?
      @follow_user = User.find(params[:user_id])
      @user.follow(params[:user_id])
      respond_to do |format|
        format.html { redirect_to request.referer }
        format.js
      end
    else
      flash[:alert] = "ログインが必要です。"
      redirect_to new_user_session_path
    end
  end

  def destroy
    @user = current_user
    @unfollow_user = User.find(params[:user_id])
    @user.unfollow(params[:user_id])
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.js
    end
  end
end
