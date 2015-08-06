class UsersController < ApplicationController

  # GET /users/1
  # GET /users/1.json
  def show

    # redirect_if_not_authorized(params[:id]) ? return : nil

    @user = User.find(params[:id])
    @active = 'notes'
    
    @page = params.has_key?(:page) && params[:page].to_i > 0 ? params[:page].to_i : 0
  
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

    @user = User.find(params[:id])
    @active = 'notes'

    respond_to do |format|
      format.json { render json: @user.items.above(params[:above]) }
    end
  end

  # GET /users/1/buckets
  # GET /users/1/buckets.json
  def buckets

    # redirect_if_not_authorized(params[:id]) ? return : nil

    @user = User.find(params[:id])
    @active = 'stacks'
    @sort = params[:s]

    respond_to do |format|
      format.html { redirect_if_not_authorized(params[:id]) ? return : nil }
      format.json { render json: { 'Other' => @user.buckets.select("buckets.*,bucket_user_pairs.last_viewed,bucket_user_pairs.unseen_items").other_type.by_first_name,  'Person' => @user.buckets.select("buckets.*,bucket_user_pairs.last_viewed,bucket_user_pairs.unseen_items").person_type.by_first_name,  'Event' => @user.buckets.select("buckets.*,bucket_user_pairs.last_viewed,bucket_user_pairs.unseen_items").event_type.order('id DESC'),  'Place' => @user.buckets.select("buckets.*,bucket_user_pairs.last_viewed,bucket_user_pairs.unseen_items").place_type.by_first_name, 'Recent' => @user.recent_buckets_with_shell } }
    end
  end

  # GET /users/1/grouped_buckets
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
    user = User.find(params[:auth][:uid])

    respond_to do |format|
      if user.update_with_params(params[:user])
        format.html { redirect_to user, notice: 'User updated.' }
        format.json { render json: { :user => user } }
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

  def reminders
    @user = User.find(params[:id])

    @page = params.has_key?(:page) && params[:page].to_i > 0 ? params[:page].to_i : 0

    respond_to do |format|
      format.html
      format.json { render json: {:reminders => @user.sorted_reminders(100000, @page).as_json(:methods => :next_reminder_date)} }
      format.js
    end
  end
end
