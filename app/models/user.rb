class User < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :images
  has_many :notifications, through: :images
  has_many :been_theres
  serialize :fb_friends

  before_create :update_fb_friends

  def as_json(options = nil)
    {
      id: id,
      name: name,
      image: image
    }.as_json(options)
  end

  def new_notifications_count
    images.joins(:notifications).where(notifications: { digested: false} ).count
  end

  def anonymous?
    fb_uid.blank?
  end

  def update_fb_friends
    if fb_uid.present?
      begin
        graph = Koala::Facebook::API.new(fb_access_token)
        friends = graph.get_connections("me", "friends")
        friends_fb_ids = friends.map { |friend| friend["id"] }
        self.fb_friends = User.where(fb_uid: friends_fb_ids).map(&:id)
      rescue => e
        self.errors[:fb_friends] = "failed to update fb friends for uid #{self.fb_uid}. #{e.message}"
      end
    end
  end

end
