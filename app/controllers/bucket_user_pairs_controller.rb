class BucketUserPairsController < ApplicationController
  # PUT /bucket_user_pairs/1
  # PUT /bucket_user_pairs/1.json
  def update
    @bup = BucketUserPair.find(params[:id])

    respond_to do |format|
      if @bup && @bup.update_attributes(params[:bucket_user_pair])
        format.json { render json: { :bucket_user_pair => @bup, :bucket => @bup.bucket.as_json(:methods => [:bucket_user_pairs, :creator]) } }
      else
        format.json { render json: @bup.errors, status: :unprocessable_entity }
      end
    end
  end
end
