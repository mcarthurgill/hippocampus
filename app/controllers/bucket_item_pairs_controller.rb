class BucketItemPairsController < ApplicationController
  # GET /bucket_item_pairs
  # GET /bucket_item_pairs.json
  def index
    @bucket_item_pairs = BucketItemPair.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bucket_item_pairs }
    end
  end

  # GET /bucket_item_pairs/1
  # GET /bucket_item_pairs/1.json
  def show
    @bucket_item_pair = BucketItemPair.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bucket_item_pair }
    end
  end

  # GET /bucket_item_pairs/new
  # GET /bucket_item_pairs/new.json
  def new
    @bucket_item_pair = BucketItemPair.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bucket_item_pair }
    end
  end

  # GET /bucket_item_pairs/1/edit
  def edit
    @bucket_item_pair = BucketItemPair.find(params[:id])
  end

  # POST /bucket_item_pairs
  # POST /bucket_item_pairs.json
  def create
    @bucket_item_pair = BucketItemPair.new(params[:bucket_item_pair])

    respond_to do |format|
      if @bucket_item_pair.save
        format.html { redirect_to @bucket_item_pair, notice: 'Bucket item pair was successfully created.' }
        format.json { render json: @bucket_item_pair, status: :created, location: @bucket_item_pair }
      else
        format.html { render action: "new" }
        format.json { render json: @bucket_item_pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bucket_item_pairs/1
  # PUT /bucket_item_pairs/1.json
  def update
    @bucket_item_pair = BucketItemPair.find(params[:id])

    respond_to do |format|
      if @bucket_item_pair.update_attributes(params[:bucket_item_pair])
        format.html { redirect_to @bucket_item_pair, notice: 'Bucket item pair was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bucket_item_pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bucket_item_pairs/1
  # DELETE /bucket_item_pairs/1.json
  def destroy
    @bucket_item_pair = BucketItemPair.find(params[:id])
    @bucket_item_pair.destroy

    respond_to do |format|
      format.html { redirect_to bucket_item_pairs_url }
      format.json { head :no_content }
    end
  end
end
