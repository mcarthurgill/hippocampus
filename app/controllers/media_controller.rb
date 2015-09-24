class MediaController < ApplicationController
  # GET /media
  # GET /media.json
  def index
    @media = Medium.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @media }
    end
  end

  # GET /media/1
  # GET /media/1.json
  def show
    @medium = Medium.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @medium }
    end
  end

  # GET /media/new
  # GET /media/new.json
  def new
    @medium = Medium.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @medium }
    end
  end

  # GET /media/1/edit
  def edit
    @medium = Medium.find(params[:id])
  end

  # POST /media
  # POST /media.json
  def create
    puts 'FILE PARAMETERS ----'
    puts params[:file]
    puts 'END PARAMS ---- '
    @medium = Medium.create_with_file_user_id_item_key_and_local_key(params[:file], params[:medium][:user_id], params[:medium][:item_local_key], params[:medium][:local_key])

    respond_to do |format|
      if @medium
        format.html { redirect_to @medium, notice: 'Medium was successfully created.' }
        format.json { render json: @medium.item }
      else
        format.html { render action: "new" }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /media/avatar
  # POST /media/avatar.json
  def create_avatar
    puts 'FILE PARAMETERS ----'
    puts params[:file]
    puts 'END PARAMS ---- '
    @medium = Medium.create_with_file_and_user_id(params[:file], params[:medium][:user_id])
    user = User.find_by_id(params[:medium][:user_id])
    if user
      user.update_attribute(:medium_id, @medium.id)
    end

    respond_to do |format|
      if @medium
        format.html { redirect_to @medium, notice: 'Medium was successfully created.' }
        format.json { render json: @medium }
      else
        format.html { render action: "new" }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /media/1
  # PUT /media/1.json
  def update
    @medium = Medium.find(params[:id])

    respond_to do |format|
      if @medium.update_attributes(params[:medium])
        format.html { redirect_to @medium, notice: 'Medium was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media/1
  # DELETE /media/1.json
  def destroy
    @medium = Medium.find_by_local_key(params[:local_key])
    @medium.destroy

    respond_to do |format|
      format.html { redirect_to media_url }
      format.json { render json: @medium.item }
    end
  end
end
