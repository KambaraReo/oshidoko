class HomesController < ApplicationController
  def index
    @user = current_user
    @all_posts = Post.includes(:favorites).all.order(created_at: :desc) # map表示用
    @posts = @all_posts.page(params[:page]) # posts表示用
  end

  def search
    @user = current_user
    @all_posts = Post.includes(:favorites).all.order(created_at: :desc)
    if params[:keyword].present?
      keywords = params[:keyword].split(/[[:blank:]]+/)
      posts = Post.left_outer_joins(:user, :members).includes(:favorites)
      keywords.inject(posts) do |result, word|
        posts = result.where(
          "title like ? OR address like ? OR description like ? OR username like ? OR name like ?",
          "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%"
        )
      end
      @posts = posts.distinct.order(created_at: :desc).page(params[:page])
    else
      @posts = @all_posts.page(params[:page])
    end
    render "index"
  end
end
