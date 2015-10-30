class Tag < ActiveRecord::Base

  attr_accessible :local_key, :number_buckets, :object_type, :tag_name, :user_id


  # ASSOCIATIONS

  belongs_to :user

  has_many :bucket_tag_pairs, dependent: :destroy
  has_many :buckets, through: :bucket_tag_pairs



  # CALLBACKS

  before_save :set_defaults
  
  def set_defaults
    self.local_key ||= "tag-#{Time.now.to_f}-#{self.user_id}" if self.user_id
  end
  
  after_save :update_underlying_objects

  def update_underlying_objects
    self.buckets.each do |bucket|
      bucket.delay.update_tags_array if bucket
    end
  end




  # HELPERS

  def user_has_access? u
    return u.id == self.user_id
  end

  def assign_number_buckets
    self.assign_attributes(number_buckets: self.buckets.count)
  end

  def update_number_buckets
    self.assign_number_buckets
    self.save!
  end

  def update_buckets_with_local_keys local_keys
    if local_keys && local_keys.count > 0
      self.buckets = Bucket.find_all_by_local_key(local_keys)
    else
      self.buckets = []
    end
    self.save!
    self.buckets.each do |bucket|
      bucket.delay.update_tags_array if bucket
    end
    self.update_number_buckets if self
    return true
  end

end
