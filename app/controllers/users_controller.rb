class UsersController < ApplicationController
  before_filter :set_user, only: [:notifications, :digest_notifications, :images, :follow, :get_followees]

  NOTIFICATIONS_COUNT = 10
  def notifications
    render json: get_notifications.as_json(user_id: @user.id)
  end

  def digest_notifications
    notifs = get_notifications
    @user.notifications.where(digested: false).update_all(digested: true)    
    render json: notifs.as_json(user_id: @user.id)
  end

  def images
    render json: @user.images.as_json(user_id: @user.id)
  end

  def has_friends?
    render text: "true"
  end

  def get_followees
    render json: @user.followees.as_json
  end

  def update_access_token
    user = User.find_by_fb_uid(params[:fb_uid])
    render json: { success: user.present? && user.update_attribute(:fb_access_token, params[:fb_access_token]) }
  end

  def follow
    by_user = User.find(params[:by_user])
    if by_user.present?
      @user.followers << by_user
      render json: { success: true }
    else
      render json: { success: false, errors: "cannot find user with id #{params[:id]}" }
    end
  end

  def unfollow
    Followship.where(follower_id: params[:by_user], followee_id: params[:id]).destroy_all
    render json: { success: true }
  end

  def signup
    if params[:fb_uid].present?
      if params[:anonymous_id].present?
        @user = User.find(params[:anonymous_id])
        @user.fb_uid = params[:fb_uid]
      else
        @user = User.find_or_initialize_by_fb_uid(params[:fb_uid])
      end
      @user.fb_access_token = params[:fb_access_token]
      @user.image = "http://graph.facebook.com/#{params[:fb_uid]}/picture?width=100&height=100"
      @user.name = params[:name] || "Facebook User"
      ##TODO : get real user name
    else
      @user = User.new
    end
    render json: { success: @user.save!, user_id: @user.id, errors: @user.errors }
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def get_notifications
    new_notifications = @user.notifications.where(digested: false)
    old_notifications = new_notifications.size < NOTIFICATIONS_COUNT ? @user.notifications.where(digested: true).order("id desc").limit(NOTIFICATIONS_COUNT - new_notifications.size) : []
    response = (new_notifications + old_notifications).sort_by(&:created_at).reverse
    # new_notifications.update_all(digested: true)    
  end

  # # GET /users
  # # GET /users.json
  # def index
  #   @users = User.all

  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @users }
  #   end
  # end

  # # GET /users/1
  # # GET /users/1.json
  # def show
  #   @user = User.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @user }
  #   end
  # end

  # # GET /users/new
  # # GET /users/new.json
  # def new
  #   @user = User.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @user }
  #   end
  # end

  # # GET /users/1/edit
  # def edit
  #   @user = User.find(params[:id])
  # end

  # # POST /users
  # # POST /users.json
  # def create
  #   @user = User.create(params[:user])
  # end

  # # PUT /users/1
  # # PUT /users/1.json
  # def update
  #   @user = User.find(params[:id])

  #   respond_to do |format|
  #     if @user.update_attributes(params[:user])
  #       format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: "edit" }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /users/1
  # # DELETE /users/1.json
  # def destroy
  #   @user = User.find(params[:id])
  #   @user.destroy

  #   respond_to do |format|
  #     format.html { redirect_to users_url }
  #     format.json { head :no_content }
  #   end
  # end
end
