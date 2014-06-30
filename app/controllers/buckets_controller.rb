class BucketsController < ApplicationController

  # POST /buckets
  # POST /buckets.json
  def create
    @bucket = Bucket.new(params[:bucket])

    respond_to do |format|
      if @bucket.save
        format.html { redirect_to @bucket, notice: 'Bucket was successfully created.' }
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
