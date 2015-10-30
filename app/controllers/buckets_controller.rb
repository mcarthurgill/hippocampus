class BucketsController < ApplicationController

  # GET /buckets/1
  # GET /buckets/1.json
  def show

    @bucket = Bucket.find(params[:id])
    @user = User.find_by_id(params[:auth][:uid]) if params.has_key?(:auth)

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
    @bucket = params[:bucket].has_key?(:local_key) ? Bucket.find_or_initialize_by_local_key(params[:bucket][:local_key]) : Bucket.new(params[:bucket])
    @bucket.assign_attributes(params[:bucket])
    user = User.find(params[:bucket][:user_id])

    respond_to do |format|
      if @bucket.save
        @bucket.add_user(user) if user
        @bucket.add_to_group_with_id_for_user(params[:group_id], user) if params.has_key?(:group_id) && user
        @bucket.add_contact_card(params[:bucket][:contact_card]) if params[:bucket].has_key?(:contact_card)
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
        format.json { render json: { :bucket => bucket.as_json(:methods => [:bucket_user_pairs, :creator]) } }
      else
        format.json { render json: bucket.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_collaborators
    bucket = Bucket.find(params[:id])
    user = User.find(params[:auth][:uid])

    bucket.remove_user_with_phone_number(format_phone(params[:phone])) if bucket && bucket.belongs_to_user?(user)

    respond_to do |format|
      if user
        format.json { render json: { :user => user, :bucket => bucket.as_json(:methods => [:bucket_user_pairs, :creator]) } }
      else
        format.json { render json: bucket.errors, status: :unprocessable_entity }
      end
    end
  end




  # SEARHORSE VERSION

  def keys
  
    user = User.find_by_id(params[:auth][:uid])

    #buckets = ["all-thoughts--#{user.id}"]+user.buckets.by_first_name.pluck(:local_key)
    buckets = user.buckets.by_first_name.pluck(:local_key)

    respond_to do |format|
      if user
        format.json { render json: buckets }
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end



  def detail
    # below_created_at = params.has_key?(:below_created_at) && params[:below_created_at].to_i > 0 ? Time.at(params[:below_created_at].to_i+1).to_datetime : Time.now+1.second

    user = User.find_by_id(params[:auth][:uid])

    if params[:id].to_i == 0
      bucket = Bucket.all_items_bucket
      item_keys = user.items.outstanding.by_date.pluck(:local_key)+user.bucket_items.by_date.not_deleted.pluck(:local_key).uniq
      # item_keys = user.bucket_items.not_deleted.order('"items"."id" DESC').merge(user.items.not_deleted.order('"items"."id" DESC')).pluck(:local_key)
      # item_keys = Item.find_by_sql(['SELECT "items"."local_key" FROM "items" INNER JOIN "bucket_item_pairs" ON "items"."id" = "bucket_item_pairs"."item_id" INNER JOIN "buckets" ON "bucket_item_pairs"."bucket_id" = "buckets"."id" INNER JOIN "bucket_user_pairs" ON "buckets"."id" = "bucket_user_pairs"."bucket_id" WHERE ("bucket_user_pairs"."phone_number" = ? OR "items"."user_id" = ?) AND (status != \'deleted\') ORDER BY "items"."id" DESC', user.phone, user.id]).map(&:local_key)

      respond_to do |format|
        if bucket && user
          format.json { render json: {:item_keys => item_keys, :bucket => bucket } }
        else
          format.json { render status: :unprocessable_entity }
        end
      end

    else
      bucket = Bucket.where("id = ?", params[:id]).includes(:bucket_user_pairs).first
      # items = bucket.items.not_deleted.by_date.limit(64) if bucket # bucket.items.not_deleted.by_date.limit(64).before_created_at(below_created_at).reverse if bucket
      item_keys = bucket.items.not_deleted.by_date.pluck(:local_key)

      respond_to do |format|
        if bucket && user && bucket.belongs_to_user?(user)
          format.json { render json: {:item_keys => item_keys, :bucket => bucket.as_json(:methods => [:bucket_user_pairs, :creator]) } }
          # format.json { render json: {:items => items, :bucket => bucket.as_json(:methods => [:bucket_user_pairs, :creator]) } }
        else
          format.json { render status: :unprocessable_entity }
        end
      end

    end

  end



  def changes
    user = User.find_by_id(params[:auth][:uid])

    buckets = params.has_key?(:updated_at_timestamp) && params[:updated_at_timestamp].length > 0 ? user.buckets.above(params[:updated_at_timestamp]) : user.buckets

    respond_to do |format|
      if user
        format.json { render json: buckets }
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end


  def update_tags
    user = User.find_by_id(params[:auth][:uid])

    bucket = Bucket.find_by_local_key(params[:local_key])

    respond_to do |format|
      if bucket.update_tags_with_local_keys_and_user(params[:local_keys], user)
        format.json { render json: bucket }
      else
        format.json { render json: bucket.errors, status: :unprocessable_entity }
      end
    end    
  end


end


