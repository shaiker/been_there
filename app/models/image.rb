class Image < ActiveRecord::Base
  attr_accessible :url, :caption, :user_id

  belongs_to :user
  has_many :views, class_name: 'ImageView'
  has_many :been_theres
  has_many :comments

  mount_uploader :url, ImageUploader
  
end
