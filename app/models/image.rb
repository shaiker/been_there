class Image < ActiveRecord::Base
  attr_accessible :url, :caption, :user_id, :categories

  belongs_to :user
  has_many :been_theres, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :notifications
  has_many :image_categories
  has_many :categories, through: :image_categories

  scope :of_friends, lambda { |user| joins("join followships on images.user_id = followee_id").where(followships: { follower_id: user.id} ).where("followee_id <> #{user.id}") }
  # scope :with_counters, 

  mount_uploader :url, ImageUploader

  RELATIVE_DATE = Time.parse("1900-01-01").to_i

  def as_json(options = {})
    {
      id: id,
      url: self.url.normal.to_s,
      thumbnail: self.url.thumbnail.to_s,
      caption: caption,
      been_theres_count: been_theres_count,
      comments_count: self["cmt_count"] || comments.count,
      been_there?: (self["is_been_there"] || been_theres.where(user_id: options[:user_id]).count).to_i > 0,
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

  def score(for_user_id, date, friends_ids)
    @score ||= {}
    key = "#{for_user_id}_#{date.to_i}"
    if @score[key].blank?
      if created_at < date
        @score[key] = age_in_days
      else
        @score[key] = 10**10 + ((10**6) * been_theres_count) + age_in_days
        @score[key] += 10**9 if friends_ids.include?(user_id)
      end
    end
    return @score[key]
  end

  def change_owner(new_user_id)
    copy = Modeless::Image.new
    copy.user_id = new_user_id
    copy.remote_url_url = self.url.url
    copy.save

    update_attributes(user_id: new_user_id)
  end

  private
  def been_theres_count
    self["bt_count"] || been_theres.count
  end

  def age_in_days
    @age_in_days ||= (created_at.to_i - RELATIVE_DATE) / 86400.0  # 60sec * 60min * 24hrs = 86400
  end

end
