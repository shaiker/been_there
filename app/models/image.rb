class Image < ActiveRecord::Base
  attr_accessible :url, :caption, :user_id, :categories

  belongs_to :user
  has_many :views, class_name: 'ImageView'
  has_many :been_theres
  has_many :comments
  has_many :notifications
  has_many :image_categories
  has_many :categories, through: :image_categories

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
      categories: categories.map(&:name)
    }.as_json(options)
  end

  def categories=(cats)
    cats = cats.present? ? [*cats] : []
    if cats.first.class.name == "String"
      Category.create_non_existing(cats)
      self.categories = Category.where(name: cats)
    else
      super(cats)
    end
  end

end
