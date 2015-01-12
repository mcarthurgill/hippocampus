class BucketItemPairsController < ApplicationController

  # POST /bucket_item_pairs
  # POST /bucket_item_pairs.json
  def create
    @bucket_item_pair = BucketItemPair.with_or_create_with_params(params[:bucket_item_pair])

    respond_to do |format|
      if @bucket_item_pair.save
        @bucket_item_pair.item.update_outstanding
        format.html { redirect_to @bucket.item, notice: 'Bucket item pair was successfully created.' }
        format.json { render json: @bucket_item_pair, status: :created, location: @bucket_item_pair }
      else
        format.html { render action: "new" }
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
