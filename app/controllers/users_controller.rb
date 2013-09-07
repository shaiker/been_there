class UsersController < ApplicationController
  
  def get_notifications
    after = Time.at((params[:after] || Time.now).to_i)
    @user = User.find(params[:id])
    been_theres = @user.images.been_theres.select("*, count(1) as count").where("created_at > ?", after).group("image_id")
    comments = @user.images.comments.select("*, count(1) as count").where("created_at > ?", after).group("image_id")
    ##TODO - all comments and been theres after given time
  end

  def images
    @user = User.find(params[:id])
    render json: @user.images.as_json(user_id: @user.id)
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
      @user.image = "http://graph.facebook.com/#{params[:fb_uid]}/picture?type=square"
      @user.name = "temp - facebook"
      ##TODO : get real user name
    else
      @user = User.new
    end
    @user.save
    render json: { user_id: @user.id }
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.create(params[:user])
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
