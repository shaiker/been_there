class BeenThere < ActiveRecord::Base
  attr_accessible :image_id, :user_id
  
  belongs_to :image
  belongs_to :user
  

end
