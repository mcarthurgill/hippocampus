class BucketItemPair < ActiveRecord::Base

  attr_accessible :bucket_id, :item_id


  # -- RELATIONSHIPS

  belongs_to :bucket
  belongs_to :item

  after_save :handle_counts
  after_destroy :handle_counts
  before_destroy :update_item_status


  def self.with_or_create_with_params params
    return self.with_or_create_with_bucket_id_and_item_id(params[:bucket_id], params[:item_id])
  end

  def self.with_or_create_with_bucket_id_and_item_id bid, iid
    bip = BucketItemPair.find_or_create_by_bucket_id_and_item_id(bid, iid)
    bip.item.update_outstanding
    bip.bucket.update_count
    return bip
  end

  def handle_counts
    self.bucket.update_count if self.bucket
    self.item.index_delayed if self.item
  end

  def update_item_status
    i = self.item
    if i.buckets.count == 1 && !i.deleted? #if after this BIP is destroyed it will have no buckets
      i.update_status("outstanding")
    end
  end
end
