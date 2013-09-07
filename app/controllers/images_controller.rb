class ImagesController < ApplicationController

  before_filter :set_user, only: [:been_there, :unbeen_there, :view, :comment, :index, :for_user]
  before_filter :set_image, only: [:comment, :comments]

  def index
    before = Time.at((params[:before] || Time.now).to_i)
    after = Time.at((params[:after] || 0).to_i)
    images = Image.where("created_at BETWEEN ? AND ?", after, before).order("created_at desc").limit(5)
    render json: images.as_json(user_id: @user.id)
  end

  def new
    @image = Image.new
  end

  def create
    image_params = params[:image] || { url: params[:url], caption: params[:caption], user_id: params[:user_id] }  ### Temporary code ###
    @image = Image.create(image_params)
    render json: { success: true }
  end


  def been_there
    Image.find(params[:id]).been_theres.find_or_create_by_user_id(user_id: @user.id)
    render json: { success: true }
  end

  def unbeen_there
    BeenThere.where(user_id: @user.id, image_id: params[:id]).destroy_all
    render json: { success: true }
  end

  def view
    Image.find(params[:id]).views.find_or_create_by_user_id(user_id: @user.id)
    render json: { success: true }
  end

  def comment
    @image.comments.create(user_id: @user.id, text: params[:text])
    render json: { success: true }
  end

  def comments
    render json: @image.comments.as_json
  end


  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_image
    @image = Image.find(params[:id])
  end

end
