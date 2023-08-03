class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def new
    @user = current_user
    @post = Post.new
  end

  def create
    @user = current_user
    @post = Post.new(post_params)
    if @post.save
      flash[:notice] = "投稿を作成しました。"
      redirect_to root_path
    else
      render "new"
    end
  end

  def show
    @user = current_user
    @post = Post.find(params[:id])
  end

  def edit
    @user = current_user
    @post = Post.find(params[:id])
    unless @user == @post.user
      flash[:alert] = "編集権限がありません。"
      redirect_to root_path
    end
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

  def destroy
    @user = current_user
    @post = Post.find(params[:id])
    @post.destroy
    flash[:notice] = "投稿を削除しました。"
    redirect_to user_path(@user)
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :address, :latitude, :longitude, :description, member_ids: [], pictures: [])
  end
end
