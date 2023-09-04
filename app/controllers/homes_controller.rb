class HomesController < ApplicationController
  def index
    @user = current_user
    # map表示用
    @all_posts = Post.all.includes(:members, user: { icon_attachment: :blob }, pictures_attachments: :blob).order(created_at: :desc)
    # posts表示用
    @posts = @all_posts.page(params[:page])
  end

  def search
    @user = current_user
    @all_posts = Post.all.includes(:members, user: { icon_attachment: :blob }, pictures_attachments: :blob).order(created_at: :desc)
    if params[:keyword].present?
      keywords = params[:keyword].split(/[[:blank:]]+/)
      posts = Post.left_outer_joins(:user, :members).includes(:members, user: { icon_attachment: :blob })
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
