class Image < ActiveRecord::Base
  attr_accessible :url, :caption, :user_id

  belongs_to :user
  has_many :views, class_name: 'ImageView'
  has_many :been_theres
  has_many :comments
  has_many :notifications

  mount_uploader :url, ImageUploader
  

  def as_json(options = nil)
    {
      id: id,
      url: self.url.normal.to_s,
      caption: caption,
      been_theres_count: been_theres.count,
      comments_count: comments.count,
      been_there?: been_theres.where(user_id: options[:user_id]).count > 0,
      created_at: created_at.to_i
    }.as_json(options)
  end

end
