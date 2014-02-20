class Tip < ActiveRecord::Base
  attr_accessible :category_id, :image_id, :text, :title, :url
end
