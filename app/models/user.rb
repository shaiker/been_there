class User < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :images
  has_many :notifications, through: :images
  has_many :been_theres

  has_many :follower_followships, class_name: "Followship", foreign_key: :followee_id, :dependent => :destroy
  has_many :followers, :class_name => "User", through: :follower_followships
  has_many :followee_followships, class_name: "Followship", foreign_key: :follower_id, :dependent => :destroy
  has_many :followees, :class_name => "User", through: :followee_followships

  before_save :update_fb_friends

  def as_json(options = nil)
    json = {
      id: id,
      name: name,
      image: image,
    }.as_json(options)
  end

  def new_notifications_count
    images.joins(:notifications).where(notifications: { digested: false} ).count
  end

  def anonymous?
    fb_uid.blank?
  end

  def update_fb_friends
    if fb_uid.present? && fb_uid_was.blank?
      begin
        graph = Koala::Facebook::API.new(fb_access_token)
        friends = graph.get_connections("me", "friends")
        friends_fb_ids = friends.map { |friend| friend["id"] }
        self.followees = User.where(fb_uid: friends_fb_ids)
      rescue => e
        self.errors[:fb_friends] = "failed to update fb friends for uid #{self.fb_uid}. #{e.message}"
      end
    end
  end

end
