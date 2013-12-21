class Category < ActiveRecord::Base
  attr_accessible :name

  has_many :image_categories
  has_many :images, through: :image_categories

  def self.create_non_existing(categories_names)
    if categories_names.present?
      existing = Category.where(name: categories_names).map(&:name)
      new_cat = categories_names - existing
      Category.create( new_cat.map { |cat| { name: cat } } ) if new_cat.any?
    end
  end

  def as_json(options = nil)
    {
      id: id,
      name: name
    }.as_json(options)
  end
end
