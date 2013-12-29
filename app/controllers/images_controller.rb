class ImagesController < ApplicationController

  before_filter :set_user, only: [:been_there, :unbeen_there, :view, :comment, :index, :for_user, :show]
  before_filter :set_image, only: [:comment, :comments, :update_caption, :been_there, :view, :destroy, :show, :update]
  before_filter :set_categories_names, only: [:index, :update]


  def index
    before = Time.at((params[:before] || Time.now).to_i - 1)
    after = Time.at((params[:after] || 0).to_i + 1)
    images = Image.where("images.created_at BETWEEN ? AND ?", after, before).order("images.created_at desc").limit(20)
    images = images.of_friends(@user) if params[:friends] == "all"
    categories = Category.where(name: @categories_names)
    images = images.includes(:image_categories).where(image_categories: { category_id: categories.map(&:id) }) if categories.present?
    render json: images.as_json(user_id: @user.id)
  end

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
