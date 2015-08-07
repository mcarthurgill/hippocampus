class BucketItemPair < ActiveRecord::Base

  attr_accessible :bucket_id, :item_id, :object_type


  # -- RELATIONSHIPS

  belongs_to :bucket
  belongs_to :item

  after_save :handle_counts
  after_create :handle_bucket_user_pairs
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

  def handle_bucket_user_pairs
    self.bucket.delay.mark_collaborators_as_unseen(self)
    self.delay.send_push_notifications
  end

  def update_item_status
    i = self.item
    if i.buckets.count == 1 && !i.deleted? #if after this BIP is destroyed it will have no buckets
      i.update_status("deleted")
    end
  end

  def send_push_notifications
    message = "#{self.item.user.name} in #{self.bucket.first_name}: #{self.item.message}"
    self.bucket.users.each do |u|
      u.send_push_notification_with_message_and_item_and_bucket(message, self.item, self.bucket) if u.id != self.item.user_id
    end
  end

end
