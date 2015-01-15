class BucketsController < ApplicationController

  # GET /buckets/1
  # GET /buckets/1.json
  def show
    @bucket = Bucket.find(params[:id])

    respond_to do |format|
        format.html
        format.json { render json: @bucket }
    end

  end


  def new
    @bucket = Bucket.new

    @item_id = (params.has_key?(:with_item) ? params[:with_item] : nil)

    respond_to do |format|
      format.html
      format.json { render json: @bucket }
    end
  end


  def edit
    @bucket = Bucket.find(params[:id])

    respond_to do |format|
      format.html
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
            redirect_to item, notice: 'Successfully added Note to Stack.' 
          else
            redirect_to @bucket, notice: 'Stack was successfully created.' 
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

    respond_to do |format|
      if @bucket.update_attributes(params[:bucket])
        format.html { redirect_to @bucket, notice: 'Bucket was successfully updated.' }
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
    @bucket.destroy

    respond_to do |format|
      format.html { redirect_to buckets_url }
      format.json { head :no_content }
    end
  end

end
