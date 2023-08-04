class FavoritesController < ApplicationController
  def create
    unless user_signed_in?
      flash[:alert] = "ログインが必要です。"
      redirect_to new_user_session_path
    else
      @favorite = Favorite.new(favorite_params)
      @favorite.save
      @post = Post.find(params[:post_id])
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
