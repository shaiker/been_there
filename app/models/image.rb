class Image < ActiveRecord::Base
  attr_accessible :url, :caption, :user_id

  belongs_to :user
  has_many :views, class_name: 'ImageView'
  has_many :been_theres
  has_many :comments
  has_many :notifications
  # has_many :categories, through: :image_categories

  scope :of_friends, lambda { |user| where(user_id: user.fb_friends) }

  mount_uploader :url, ImageUploader
  

  def as_json(options = nil)
    {
      id: id,
      url: self.url.normal.to_s,
      caption: caption,
      been_theres_count: been_theres.count,
      comments_count: comments.count,
      been_there?: been_theres.where(user_id: options[:user_id]).count > 0,
      created_at: created_at.to_i,
      user: user.as_json(options),
      categories: ["eat", "sleep", "rave", "repeat"]
    }.as_json(options)
  end

end
