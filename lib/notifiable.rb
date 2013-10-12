module Notifiable

  def self.included(base)
    base.after_create :create_notification
  end

  def create_notification
    image.notifications.create(generated_by_user_id: user.id, notification_type: Notification::TYPES[self.class.name.underscore.to_sym]) if image.user.id != user.id
  end    

end
