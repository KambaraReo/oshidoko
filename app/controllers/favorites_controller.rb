class FavoritesController < ApplicationController
  def show
    @user = current_user
    @post = Post.find(params[:post_id])
    @favorited_users = @post.favorited_users.includes(:members, icon_attachment: :blob)
  end

  def create
    if user_signed_in?
      @favorite = Favorite.new(favorite_params)
      @favorite.save
      @post = Post.find(params[:post_id])
    else
      flash[:alert] = "ログインが必要です。"
      redirect_to new_user_session_path
    end
  end

  def destroy
    @favorite = Favorite.find_by(favorite_params)
    @favorite.destroy
    @post = Post.find(params[:post_id])
  end

  private

  def favorite_params
    { post_id: params[:post_id], user_id: current_user.id }
  end
end
