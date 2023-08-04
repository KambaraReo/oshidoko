class HomesController < ApplicationController
  def index
    @user = current_user
    @all_posts = Post.includes(:favorites).all.order(created_at: :desc) # map表示用
    @posts = @all_posts.page(params[:page]) # posts表示用
  end
end
