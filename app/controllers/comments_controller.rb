class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    post = Post.find(params[:post_id])
    comment = post.comments.build(comment_params)
    comment.user = current_user

    if comment.save
      redirect_to post
    else
      redirect_to post, alert: "Comment could not be saved"
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    post = comment.post

    comment.destroy if comment.user == current_user
    redirect_to post
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
