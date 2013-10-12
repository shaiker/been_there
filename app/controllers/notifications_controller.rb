class NotificationsController < ApplicationController

  def opened
    Notification.where(id: params[:id]).update_all(opened: true)
    render json: { success: true }
  end

end
