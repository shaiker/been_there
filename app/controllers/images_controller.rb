class ImagesController < ApplicationController

  before_filter :set_user, except: [:new, :create]
  before_filter :set_image, except: [:index, :new, :create]

  def index
    before = Time.at((params[:before] || Time.now).to_i)
    after = Time.at((params[:after] || 0).to_i)
    images = Image.where("created_at BETWEEN ? AND ?", after, before).order("created_at desc").limit(5)
    render json: images_json(images)
  end

  def for_user
    ##TODO : image stream of specific user
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


  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def set_image
    @image = Image.find(params[:id])
  end


  def images_json(images)
    images.map do |image| 
      {
        id: image.id,
        url: "http://kokavo.com" + image.url.to_s,
        been_theres_count: image.been_theres.count,
        comments_count: image.comments.count,
        comments: comments_json(image.comments.first(3)),
        been_there?: image.been_theres.where(user_id: @user.id).count > 0,
        created_at: image.created_at.to_i
      }
    end
  end

  def comments_json(comments)
    comments.map do |comment|
      {
        user: comment.user.as_json,
        text: comment.text
      }
    end
  end

end
