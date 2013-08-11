class Comment < ActiveRecord::Base
  attr_accessible :image_id, :text, :user_id
  belongs_to :image
  belongs_to :user
end
