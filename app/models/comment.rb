class Comment < ActiveRecord::Base
  attr_accessible :image_id, :text, :user_id
  belongs_to :image
  belongs_to :user


  def as_json(options = nil)
    {
      id: id,
      user: user.as_json(options),
      text: text
    }.as_json(options)
  end
end
