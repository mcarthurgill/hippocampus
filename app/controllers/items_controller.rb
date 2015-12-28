class ItemsController < ApplicationController

  include Formatting
  
  def index
    @new_users_last_24_hours = User.where("created_at > ?", 1.day.ago).count
    @new_users_last_week = User.where("created_at > ?", 7.days.ago).count
    @users_added_item_last_24_hours = Item.where("created_at > ? AND user_id NOT IN (?)", 1.day.ago, [23, 2, 18, 15, 81, 189, 190, 191, 30]).pluck(:user_id).uniq.count
    @users_added_item_last_week = Item.where("created_at > ? AND user_id NOT IN (?)", 7.days.ago, [23, 2, 18, 15, 81, 189, 190, 191, 30]).pluck(:user_id).uniq.count

    @items = Item.where("user_id != ? AND user_id != ? AND user_id != ? AND user_id != ? AND user_id != ? AND user_id != ? AND user_id != ? AND user_id != ?", 23, 2, 18, 15, 81, 189, 190, 191).order('id DESC').limit(512).not_deleted
    if params.has_key?(:admin) && params[:admin] == 'snickers'
      render layout: false
    else
      render nothing: true
    end
  end

  def show
    @item = Item.find(params[:id])
    curr_user = (params[:auth] && params[:auth][:uid] && params[:auth][:uid].length > 0) ? User.find(params[:auth][:uid]) : nil
    @active = 'notes'

    respond_to do |format|
      if curr_user
        format.html { redirect_if_not_authorized(@item.user_id) ? return : nil }
        format.json { render json: @item.json_representation(curr_user) }
      else
        format.html { redirect_if_not_authorized(@item.user_id) ? return : nil }
        format.json { render json: @item.as_json(methods: [:buckets, :user]) }
      end
    end
  end


  # POST /items
  # POST /items.json
  def create
    
    @item = nil
    
    if params[:item].has_key?(:device_timestamp) && params[:item][:device_timestamp].to_f > 0
      @item = Item.find_by_device_timestamp_and_user_id(params[:item][:device_timestamp], params[:item][:user_id])
    end
    
    upload_files = false

    if !@item

      @item = Item.new(params[:item])
      upload_files = true

    end

    respond_to do |format|
      if @item.save

        if upload_files && params[:item].has_key?(:file) && params[:item][:file]
          Medium.create_with_file_user_id_and_item_id(params[:item][:file], @item.user_id, @item.id)
        elsif upload_files && params.has_key?(:file) && params[:file]
          Medium.create_with_file_user_id_and_item_id(params[:file], @item.user_id, @item.id)          
        elsif upload_files && params.has_key?(:media) && params[:media]
          params[:media].each do |medium|
            Medium.create_with_file_user_id_and_item_id(medium, @item.user_id, @item.id)
          end
        end

        @item.add_to_bucket(Bucket.find(params[:item][:bucket_id])) if params[:item][:bucket_id] && params[:item][:bucket_id].length > 0 && params[:item][:bucket_id].to_i > 0
        @item.add_to_bucket(Bucket.find_by_local_key(params[:item][:bucket_local_key])) if params[:item][:bucket_local_key] && params[:item][:bucket_local_key].length > 0

        format.html { redirect_to item_path(@item) }
        format.json { render json: Item.find(@item.id), status: :created, location: @item } #rails was caching @item and not sending back the updated status if we were assigning to a bucket. 
      else
        format.html { redirect_to new_item_path, :notice => "Error creating note." }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end

  end


  def new
    @item = Item.new
    @active = 'notes'
    @options_for_buckets = current_user.formatted_buckets_options

    respond_to do |format|
      format.html 
      format.json { render json: @item }
    end
  end


  def edit
    @item = Item.find(params[:id])

    # redirect_if_not_authorized(@item.user_id) ? return : nil

    @active = 'notes'

    @options_for_buckets = current_user.formatted_buckets_options

    respond_to do |format|
      format.html { redirect_if_not_authorized(@item.user_id) ? return : nil }
      format.json { head :no_content }
    end
  end
  

  def assign
    @item = Item.find(params[:id])

    # redirect_if_not_authorized(@item.user_id) ? return : nil

    @active = 'notes'
    @user = current_user
    # @sort_by = params.has_key?(:sort_by) ? params[:sort_by] : 'alphabetical'
    @sort_by = 'type'

    @options_for_buckets = @item.user.formatted_buckets_options

    respond_to do |format|
      format.html { redirect_if_not_authorized(@item.user_id) ? return : nil }
      format.json { head :no_content }
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = Item.find(params[:id])

    # redirect_if_not_authorized(@item.user_id) ? return : nil

    respond_to do |format|
      if @item.is_most_recent_request?(params[:item][:device_request_timestamp]) && @item.update_attributes(params[:item])
        @item.update_outstanding
        @item.remove_nudge_if_needed
        format.html { redirect_to item_path(@item), :notice => "Note updated." }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_item_path(@item), :notice => "Sorry that didn't work" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = Item.find(params[:id])

    # redirect_if_not_authorized(@item.user_id) ? return : nil
    
    @item.update_status("deleted")
    @item.buckets.each {|b| b.update_count }

    respond_to do |format|
      format.html { redirect_to user_path(current_user), :notice => "Note deleted successfully." }
      format.json { head :no_content }
    end
  end

  def random_items
    user = User.find(params[:user_id])
    limit = params[:limit] && params[:limit].length > 0 ? params[:limit] : 15
    items = user.items.not_deleted.limit(limit).order("RANDOM()") if user

    respond_to do |format|
      if user && items
        format.html
        format.json { render json: { items: items } }
      else
        format.html { redirect_to user_path(current_user), :notice => "Something went wrong" }
        format.json { head :no_content }
      end
    end
  end

  def near_location
    user = User.find(params[:user_id])
    
    items = user.items_near_location(params[:longitude], params[:latitude]) if user

    respond_to do |format|
      if user && items
        format.html
        format.json { render json: { items: items } }
      else
        format.html { redirect_to user_path(current_user), :notice => "Something went wrong" }
        format.json { head :no_content }
      end
    end
  end

  def within_bounds
    user = User.find(params[:user_id])
    
    items = user.items_within_bounds(params[:centerx], params[:centery], params[:dx], params[:dy]) if user

    respond_to do |format|
      if user && items
        format.html
        format.json { render json: { items: items } }
      else
        format.html { redirect_to user_path(current_user), :notice => "Something went wrong" }
        format.json { head :no_content }
      end
    end
  end



  # SEAHORSE VERSION

  def changes
    user = User.find_by_id(params[:auth][:uid])

    items = params.has_key?(:updated_at_timestamp) && params[:updated_at_timestamp].length > 0 ? user.items.outstanding.above(params[:updated_at_timestamp]).by_date.limit(512)+user.bucket_items.not_deleted.above(params[:updated_at_timestamp]).by_date.limit(512) : user.items.not_deleted.by_date.limit(512)

    respond_to do |format|
      if user
        format.json { render json: items }
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end


  def update_buckets
    user = User.find_by_id(params[:auth][:uid])

    item = Item.find_by_local_key(params[:local_key])

    respond_to do |format|
      if item.update_buckets_with_local_keys_and_user(params[:local_keys], user)
        format.json { render json: item }
      else
        format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end    
  end

end
