class BucketItemPair < ActiveRecord::Base

  attr_accessible :bucket_id, :item_id


  # -- RELATIONSHIPS

  belongs_to :bucket
  belongs_to :item



  def self.with_or_create_with_params params
    bip = BucketItemPair.find_or_initialize_by_bucket_id_and_item_id(params[:bucket_id], params[:item_id])
    bip.save!
    return bip
  end

end
