class BucketsController < ApplicationController

  # GET /buckets/1
  # GET /buckets/1.json
  def show

    @bucket = Bucket.find(params[:id])

    # redirect_if_not_authorized(@bucket.user_id) ? return : nil

    @active = 'stacks'
    @page = params.has_key?(:page) && params[:page].to_i > 0 ? params[:page].to_i : 0

    respond_to do |format|
        format.html { redirect_if_not_authorized(@bucket.user_id) ? return : nil }
        format.json { render json: {:items => @bucket.items.not_deleted.by_date.limit(64).offset(64*@page).reverse, :page => @page } }
    end

  end


  def new
    @bucket = Bucket.new
    @active = 'stacks'

    @item_id = (params.has_key?(:with_item) ? params[:with_item] : nil)

    respond_to do |format|
      format.html
      format.json { render json: @bucket }
    end
  end


  def edit
    @bucket = Bucket.find(params[:id])

    # redirect_if_not_authorized(@bucket.user_id) ? return : nil

    @active = 'stacks'

    respond_to do |format|
      format.html { redirect_if_not_authorized(@bucket.user_id) ? return : nil }
      format.json { head :no_content }
    end
  end


  # POST /buckets
  # POST /buckets.json
  def create
    @bucket = Bucket.new(params[:bucket])

    respond_to do |format|
      if @bucket.save
        format.html do 
          if params.has_key?(:with_item) && params[:with_item].to_i > 0
            item = Item.find(params[:with_item])
            item.add_to_bucket(@bucket)
            redirect_to item, notice: "Added note to the '#{@bucket.display_name}' stack."
          else
            redirect_to @bucket, notice: 'Stack created!' 
          end
        end
        format.json { render json: @bucket, status: :created, location: @bucket }
      else
        format.html { render action: "new" }
        format.json { render json: @bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /buckets/1
  # PUT /buckets/1.json
  def update
    @bucket = Bucket.find(params[:id])

    # redirect_if_not_authorized(@bucket.user_id) ? return : nil
    bucket_name_changed = @bucket.first_name == params[:bucket][:first_name]

    respond_to do |format|
      if @bucket.update_attributes(params[:bucket])
        @bucket.delay.update_items_with_new_bucket_name if bucket_name_changed
        format.html { redirect_to @bucket, notice: 'Stack updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buckets/1
  # DELETE /buckets/1.json
  def destroy
    @bucket = Bucket.find(params[:id])

    # redirect_if_not_authorized(@bucket.user_id) ? return : nil
    
    @bucket.destroy

    respond_to do |format|
      format.html { redirect_to current_user }
      format.json { head :no_content }
    end
  end

  def media_urls
    bucket = Bucket.find(params[:id])
    user = User.find(params[:user_id])

    urls = bucket.get_media_urls if (bucket && bucket.user == user)

    respond_to do |format|
      format.json { render json: { :media_urls => urls } }
    end
  end
end
