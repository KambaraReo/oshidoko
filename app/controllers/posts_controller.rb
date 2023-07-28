class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @posts = @user.posts
  end

  def new
    @user = current_user
    @post = Post.new
  end

  def create
    @user = current_user
    @post = Post.new(post_params)
    if @post.save
      redirect_to root_path
    else
      render "new"
    end
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :address, :latitude, :longitude, :description, :picture, member_ids: [])
  end
end
