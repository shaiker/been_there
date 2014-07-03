class ImagesController < ApplicationController

  before_filter :set_user, only: [:been_there, :unbeen_there, :view, :comment, :index, :feed, :for_user, :show]
  before_filter :set_image, only: [:comment, :comments, :update_caption, :been_there, :view, :destroy, :show, :update]
  before_filter :set_categories_names, only: [:index, :feed, :update]


  #for sorting also the catergories feed & the only-friends feed, also by the algorithm
  # def feed 
  #   images = Image.joins("LEFT OUTER JOIN been_theres ON images.id = been_theres.image_id").select("images.*, COUNT(been_theres.image_id) as bt_count").group("images.id")    
  #   if params[:friends] == "all"
  #     images = images.of_friends(@user)
  #   end
  #   if (categories = Category.where(name: @categories_names).present?)
  #     images = images.includes(:image_categories).where(image_categories: { category_id: categories.map(&:id) })
  #   end
  #   friends_ids = @user.present? ? @user.followees.map(&:id) : []
  #   time = Time.at(params[:last_login].try(:to_i) || 0)      
  #   images.sort! { |a, b| a.score(@user.id, time, friends_ids) <=> b.score(@user.id, time, friends_ids) }
  #   render json: images.as_json(user_id: @user.id)
  # end

  def feed
    start = Time.now
    images = Image.includes(:user, :categories)
                  .select("images.*, COUNT(DISTINCT been_theres.id) AS bt_count, COUNT(DISTINCT comments.id) AS cmt_count, MAX(CASE WHEN been_theres.user_id = #{@user.id} THEN 1 ELSE 0 END) AS is_been_there")
                  .joins("LEFT OUTER JOIN been_theres ON images.id = been_theres.image_id LEFT OUTER JOIN comments on images.id = comments.image_id")
                  .group("images.id")    
    if params[:friends] == "all"
      images = images.of_friends(@user).order("images.created_at DESC") 
    elsif (categories = Category.where(name: @categories_names)).present?
      images = images.includes(:image_categories).where(image_categories: { category_id: categories.map(&:id) }).order("images.created_at DESC") 
    else
      friends_ids = @user.followees.map(&:id)
      time = Time.at(params[:last_login].try(:to_i) || 0)
      images.sort! { |a, b| b.score(@user.id, time, friends_ids) <=> a.score(@user.id, time, friends_ids) }
    end
    result = images.first(50).as_json(user_id: @user.id)
    Rails.logger.info "----- Took: #{Time.now - start} sec"
    render json: result
  end

  def index #this can be deleted when Inbal start using the /feed API
    before = Time.at((params[:before] || Time.now).to_i - 1)
    after = Time.at((params[:after] || 0).to_i + 1)
    images = Image.where("images.created_at BETWEEN ? AND ?", after, before).order("images.created_at desc").limit(20)
    images = Image.of_friends(@user).order("images.created_at desc") if params[:friends] == "all"
    categories = Category.where(name: @categories_names)
    images = images.includes(:image_categories).where(image_categories: { category_id: categories.map(&:id) }) if categories.present?
    render json: images.as_json(user_id: @user.id)
  end

  # def index #Old version index for backward competability
  #   before = Time.at((params[:before] || Time.now).to_i - 1)
  #   after = Time.at((params[:after] || 0).to_i + 1)
  #   images = Image.where("created_at BETWEEN ? AND ?", after, before).order("created_at desc").limit(20)
  #   render json: images.as_json(user_id: @user.id)
  # end

  def show
    render json: @image.as_json(user_id: @user.id)
  end

  def new
    @image = Image.new
  end

  def create
    image_params = params[:image] || { url: params[:url], caption: params[:caption], user_id: params[:user_id], categories: params[:categories] }  ### Temporary code ###
    @image = Image.create(image_params)
    render json: @image.as_json(user_id: params[:user_id])
  end

  def update_caption
    @image.caption = params[:caption]
    @image.save
    render json: { success: true }
  end

  def update
    @image.caption = params[:caption]
    @image.categories = @categories_names if @categories_names.present?

    render json: { success: @image.save!, errors: (@image.errors if @image.errors.any?) }
  end

  def been_there
    @image.been_theres.find_or_create_by_user_id(user_id: @user.id)
    render json: { success: true }
  end

  def been_there_users
    render json: User.includes(:been_theres).where(been_theres: { image_id: params[:id] })
  end

  def unbeen_there
    BeenThere.where(user_id: @user.id, image_id: params[:id]).destroy_all
    render json: { success: true }
  end

  def view
    @image.views.find_or_create_by_user_id(user_id: @user.id)
    render json: { success: true }
  end

  def comment
    @image.comments.create(user_id: @user.id, text: params[:text])
    render json: { success: true }
  end

  def comments
    render json: @image.comments.as_json
  end

  def destroy
    render json: { success: !!@image.destroy }
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_image
    @image = Image.find(params[:id])
  end

  def set_categories_names 
    @categories_names = [*params[:categories]].map(&:downcase) if params[:categories].present?
  end
end
