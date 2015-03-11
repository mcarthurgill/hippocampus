class ItemsController < ApplicationController

  def index
    @items = Item.order('id DESC').limit(512)

    render layout: false
  end

  def show
    @item = Item.find(params[:id])

    # redirect_if_not_authorized(@item.user_id) ? return : nil

    @active = 'notes'

    respond_to do |format|
      format.html { redirect_if_not_authorized(@item.user_id) ? return : nil }
      format.json { render json: @item.as_json(methods: :buckets) }
    end
  end


  # POST /items
  # POST /items.json
  def create
    
    @item = nil
    
    if params[:item].has_key?(:device_timestamp) && params[:item][:device_timestamp].to_f > 0
      @item = Item.find_by_device_timestamp_and_user_id(params[:item][:device_timestamp], params[:item][:user_id])
    end

    if !@item

      @item = Item.new(params[:item])
      
      if params[:item].has_key?(:file) && params[:item][:file]
        @item.upload_main_asset(params[:item][:file])
      elsif params.has_key?(:file) && params[:file]
        @item.upload_main_asset(params[:file])
      end

    end

    respond_to do |format|
      if @item.save
        @item.add_to_bucket(Bucket.find(params[:item][:bucket_id])) if params[:item][:bucket_id] && params[:item][:bucket_id].length > 0 && params[:item][:bucket_id].to_i > 0

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
      if user && items && items.count > 0
        format.html
        format.json { render json: { items: items } }
      else
        format.html { redirect_to user_path(current_user), :notice => "Something went wrong" }
        format.json { head :no_content }
      end
    end
  end

end
