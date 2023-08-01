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

  def edit
    @user = current_user
    @post = Post.find(params[:id])
  end

  def update
    @user = current_user
    @post = Post.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = "投稿を更新しました。"
      redirect_to user_path(@user)
    else
      render "edit"
    end

  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :address, :latitude, :longitude, :description, :picture, member_ids: [])
  end
end
