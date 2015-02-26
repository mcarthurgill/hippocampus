class BucketItemPairsController < ApplicationController

  # POST /bucket_item_pairs
  # POST /bucket_item_pairs.json
  def create
    @bucket_item_pair = BucketItemPair.with_or_create_with_params(params[:bucket_item_pair])

    respond_to do |format|
      if @bucket_item_pair.save
        format.html { redirect_to @bucket_item_pair.item, notice: "Added note to the '#{@bucket_item_pair.bucket.display_name}' stack." }
        format.json { render json: @bucket_item_pair.item.as_json(methods: :buckets) }
      else
        format.html { render action: "new" }
        format.json { render json: @bucket_item_pair.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy_with_bucket_and_item
    item = Item.find(params[:item_id])
    @bucket_item_pair = BucketItemPair.find_by_bucket_id_and_item_id(params[:bucket_id], item.id)
    @bucket_item_pair.destroy

    item.delay.update_buckets_string

    respond_to do |format|
      format.html { redirect_to bucket_item_pairs_url }
      format.json { render json: item.as_json(methods: :buckets) }
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
