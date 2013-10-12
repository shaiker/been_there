class User < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :images
  has_many :notifications, through: :images

  def as_json(options = nil)
    {
      id: id,
      name: name,
      image: image
    }.as_json(options)
  end

end
