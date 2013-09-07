class User < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :images

  def as_json(options = nil)
    {
      name: name,
      image: image
    }.as_json(options)
  end

end
