class UsersController < ApplicationController
  before_filter :get_most_recent_buckets, [:buckets, :items]

  # GET /users/1
  # GET /users/1.json
  def show

    # redirect_if_not_authorized(params[:id]) ? return : nil
    @user = User.find(params[:id])
    @active = 'profile'
      
    respond_to do |format|
      format.html { redirect_if_not_authorized(params[:id]) ? return : nil }
      format.json do 
        if @page > 0
          render json: { :bottom_items => @user.items.by_date.assigned.limit(64).offset(64*@page).reverse, :page => @page, :count => 64, :number_items => @user.number_items, :number_buckets => @user.number_buckets, :score => @user.score, :email => @user.email, :salt => @user.salt, :phone => @user.phone }
        else
          render json: { :outstanding_items => @user.items.by_date.outstanding.reverse, :items => @user.items.by_date.assigned.limit(64).offset(64*@page).reverse, :page => @page, :number_items => @user.number_items, :number_buckets => @user.number_buckets, :score => @user.score, :setup_completion => @user.setup_completion, :email => @user.email, :salt => @user.salt, :phone => @user.phone }
        end
      end
      format.js
    end
  end

  # GET /users/1/items
  # GET /users/1/items.json
  def items

    # redirect_if_not_authorized(params[:id]) ? return : nil

    @user = User.where("id = ?", params[:id]).first
    @active = 'thoughts'
    page = get_page(params[:page])
    @items = []
    if page > 0 
      @items = @user.bucket_items.by_date.not_deleted.for_page_with_limit(page, 25).includes(:buckets).uniq.reverse
    else 
      @items = (@user.items.outstanding.by_date.includes(:buckets)+@user.bucket_items.by_date.not_deleted.for_page_with_limit(page, 25).includes(:buckets)).uniq.reverse
    end
    @item = Item.new

    respond_to do |format|
      format.js
      format.html
      format.json { render json: @items }
    end
  end

  # GET /users/1/buckets
  # GET /users/1/buckets.json
  def buckets

    # redirect_if_not_authorized(params[:id]) ? return : nil

    @user = User.find(params[:id])
    @active = 'buckets'
    @page = get_page(params[:page])
    @append = params[:append] && params[:append] == "true" ? true : false
    @buckets = params[:sort] == "date" ? @user.buckets.recent_first.for_page_with_limit(@page, 25) : @user.buckets.by_first_name.for_page_with_limit(@page, 25)
    @user.delay.should_update_last_activity
    @item = Item.new
    @new_bucket = Bucket.new
    
    respond_to do |format|
      format.html { redirect_if_not_authorized(params[:id]) ? return : nil }
      format.js
    end
  end

  # GET /users/1/grouped
  # GET /users/1/grouped_buckets.json
  def grouped_buckets
    # redirect_if_not_authorized(params[:id]) ? return : nil
    @user = User.find(params[:id])

    respond_to do |format|
      # format.html { redirect_if_not_authorized(params[:id]) ? return : nil }
      format.json { render json: { 'Recent' => @user.recent_buckets_with_shell, 'groups' => @user.groups.alphabetical.includes(:buckets).as_json(methods: [:sorted_buckets]), 'buckets' => @user.ungrouped_buckets } }
    end
  end

  # # POST /users
  # # POST /users.json
  # def create
    #login/signup runs through sessions controller
  # end

  def update
    user = User.find(params[:auth][:uid]) if params.has_key?(:auth)
    user = current_user if current_user

    respond_to do |format|
      if user && user.update_with_params(params[:user])
        format.html { redirect_to user, notice: 'User updated.' }
        format.json do 
          if params.has_key?(:v) && params[:v].to_f >= 2.0
            render json: user
          else
            render json: { user: user }
          end
        end
      else
        format.html { render action: "edit" }
        format.json { render json: user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    # redirect_if_not_authorized(params[:id]) ? return : nil

    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def add_to_addon

    user = User.find(params[:id])
    addon = Addon.find(params[:addon_id])
    respond_to do |format|
      if user.add_to_addon(addon)
        format.html { redirect_to user_path(user), :notice => "Great Success!" }
      else
        format.html { redirect_to user_path(user), :notice => "Whoops. Try that again!" }
      end
    end
  end

  def remove_from_addon
    user = User.find(params[:id])
    addon = Addon.find(params[:addon_id])
    respond_to do |format|
      if user.remove_from_addon(addon)
        format.html { redirect_to user_path(user), :notice => "Great Success!" }
      else
        format.html { redirect_to user_path(user), :notice => "Whoops. Try that again!" }
      end
    end
  end



  # SEAHORSE

  def avatar
    user = User.find_by_id(params[:id])
    if user
      redirect_to user.avatar_path
      return
    else
      redirect_to "https://res.cloudinary.com/hbztmvh3r/image/upload/v1440726309/avatar_#{Time.now.to_i%3}.jpg"
      return
    end
  end

  def phone_avatar
    user = User.find_by_phone(params[:phone])
    if user
      redirect_to user.avatar_path
      return
    else
      redirect_to "https://res.cloudinary.com/hbztmvh3r/image/upload/v1440726309/avatar_#{Time.now.to_i%3}.jpg"
      return
    end
  end

  def reminders
    user = User.find(params[:id])

    page = get_page(params[:page])
    mobile = params[:auth] && params[:auth][:uid]
    @active = "nudges"

    @reminders = user.sorted_reminders(25, page, mobile)
    list = @reminders.shift(1).first if mobile

    respond_to do |format|
      if current_user #this is a janky fix til we get the .json on the reminders call from iOS 
        format.html
      end
      format.json { render json: {:reminders => @reminders, :nudge_list => list[:nudges_list]} }
    end
  end
end
