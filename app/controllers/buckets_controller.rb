class BucketsController < ApplicationController

  # GET /buckets/1
  # GET /buckets/1.json
  def show

    @bucket = Bucket.find(params[:id])
    @user = User.find_by_id(params[:auth][:uid])

    # redirect_if_not_authorized(@bucket.user_id) ? return : nil

    @active = 'stacks'
    @page = params.has_key?(:page) && params[:page].to_i > 0 ? params[:page].to_i : 0

    @bucket.delay.viewed_by_user_id(params[:auth][:uid]) if params.has_key?(:auth)

    respond_to do |format|
        format.html { redirect_if_not_authorized(@bucket.user_id) ? return : nil }
        format.json { render json: {:items => @bucket.items.not_deleted.by_date.limit(64).offset(64*@page).reverse, :page => @page, :group => @bucket.group_for_user(@user) } }
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
    user = User.find(params[:bucket][:user_id])

    respond_to do |format|
      if @bucket.save
        @bucket.add_user(user) if user
        @bucket.add_to_group_with_id_for_user(params[:group_id], user) if params.has_key?(:group_id) && user
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

    urls = bucket.media_urls if (bucket && bucket.belongs_to_user?(user))

    respond_to do |format|
      format.json { render json: { :media_urls => urls } }
    end
  end

  def info
    page = params.has_key?(:page) && params[:page].to_i > 0 ? params[:page].to_i : 0

    bucket = Bucket.where("id = ?", params[:id]).includes(:bucket_user_pairs).first
    user = User.find_by_id(params[:auth][:uid])
    items = bucket.items.not_deleted.by_date.limit(64).offset(64*page).reverse if bucket

    respond_to do |format|
      if bucket && user && bucket.belongs_to_user?(user)
        format.json { render json: {:items => items, :page => page, :bucket => bucket.as_json(:methods => [:bucket_user_pairs, :media_urls, :creator, :contact_cards]), :group => bucket.group_for_user(user) } }
      else
        format.json { render json: bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_group_for_user
    bucket_user_pair = BucketUserPair.find_by_bucket_id_and_user_id(params[:bucket_id], params[:user_id])
    bucket_user_pair.update_attribute(:group_id, (params[:group_id] && params[:group_id].to_i > 0 ? params[:group_id] : nil))
    respond_to do |format|
      format.json { render json: bucket_user_pair }
    end
  end

  def add_collaborators
    bucket = Bucket.find(params[:id])
    user = User.find(params[:auth][:uid])

    bucket.add_collaborators_from_contacts_with_calling_code(params[:contacts], User.find_by_id(params[:auth][:uid]).calling_code, user) if bucket && bucket.belongs_to_user?(user)

    respond_to do |format|
      if bucket
        format.json { render json: { :bucket => bucket } }
      else
        format.json { render json: bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_collaborators
    bucket = Bucket.find(params[:id])
    user_to_remove = User.find_by_phone(params[:phone])
    user = User.find(params[:auth][:uid])

    bucket.remove_user(user_to_remove) if bucket && bucket.belongs_to_user?(user) && user_to_remove

    respond_to do |format|
      if user
        format.json { render json: { :user => user } }
      else
        format.json { render json: bucket.errors, status: :unprocessable_entity }
      end
    end
  end
end
