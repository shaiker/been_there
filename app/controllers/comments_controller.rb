class CommentsController < ApplicationController

  before_filter :set_comment, only: [:destroy, :update]

  def destroy
    @comment.destroy
    render json: { success: true }
  end

  def update
    user = User.find_by_id(params[:user_id])
    rslt = false
    if user.present?
      if @comment.user == user
        @comment.text = params[:text]
        rslt = @comment.save
        error = @comment.errors
      else
        error = "unauthorized user trying to update a comment that is not his own"
      end
    else
      error = "could not find user with given user_id"
    end
    render json: { success: rslt, error: error }
  end

  private
  def set_comment
    @comment = Comment.find(params[:id])
  end

end
