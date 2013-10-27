class MainController < ApplicationController

  def send_feedback
    Feedback.create(user_id: params[:user_id], text: params[:text])
    render json: { success: true }
  end
end
