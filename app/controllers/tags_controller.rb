class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.json
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(params[:tag])

    @tag = params[:tag].has_key?(:local_key) ? Tag.find_or_initialize_by_local_key(params[:tag][:local_key]) : Tag.new(params[:tag])
    @tag.assign_attributes(params[:tag])
    user = User.find(params[:tag][:user_id])

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { render action: "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.json
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to tags_url }
      format.json { head :no_content }
    end
  end



  # SEAHORSE

  def keys
  
    user = User.find_by_id(params[:auth][:uid])

    tags = user.tags.order('tag_name ASC').pluck(:local_key)

    respond_to do |format|
      if user
        format.json { render json: tags }
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end

  def update_buckets
    user = User.find_by_id(params[:auth][:uid])

    tag = Tag.find_by_local_key(params[:local_key])

    respond_to do |format|
      if tag.update_buckets_with_local_keys(params[:local_keys])
        format.json { render json: tag }
      else
        format.json { render json: tag.errors, status: :unprocessable_entity }
      end
    end    
  end

  def changes
    user = User.find_by_id(params[:auth][:uid])

    tags = params.has_key?(:updated_at_timestamp) && params[:updated_at_timestamp].length > 0 ? user.tags.above(params[:updated_at_timestamp]) : user.tags

    respond_to do |format|
      if user
        format.json { render json: tags }
      else
        format.json { render status: :unprocessable_entity }
      end
    end

  end


end
