class BucketItemPair < ActiveRecord::Base

  attr_accessible :bucket_id, :item_id


  # -- RELATIONSHIPS

  belongs_to :bucket
  belongs_to :item



  def self.with_or_create_with_params params
    return self.with_or_create_with_bucket_id_and_item_id(params[:bucket_id], params[:item_id])
  end

  def self.with_or_create_with_bucket_id_and_item_id bid, iid
    bip = BucketItemPair.find_or_create_by_bucket_id_and_item_id(bid, iid)
    bip.item.update_outstanding
    bip.bucket.increment_count
    return bip
  end

end
