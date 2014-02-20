class ImageCategory < ActiveRecord::Base
  attr_accessible :category_id, :image_id

  belongs_to :image
  belongs_to :category
  
end
