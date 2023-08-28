class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:create, :destroy]

  def create
    @user = current_user
    if user_signed_in?
      @post = Post.find(params[:post_id])
      @comment = @user.comments.new(comment_params)
      @comment.post_id = @post.id
      respond_to do |format|
        if @comment.save
          @comments = @post.comments
          format.html { redirect_to @post }
          format.js { render :create }
        else
          @comments = @post.comments
          format.html { redirect_to @post }
          format.js { render :create_error }
        end
      end
    else
      flash[:alert] = "ログインが必要です。"
      redirect_to new_user_session_path
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = Comment.find(params[:id])
    @comment.destroy
    @comments = @post.comments
  end

  private

  def comment_params
    params.require(:comment).permit(:user_id, :post_id, :comment, :rate)
  end
end
