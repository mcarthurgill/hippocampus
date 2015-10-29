class Tag < ActiveRecord::Base

  attr_accessible :local_key, :number_buckets, :object_type, :tag_name, :user_id


  # ASSOCIATIONS

  belongs_to :user

  has_many :bucket_tag_pairs, dependent: :destroy
  has_many :buckets, through: :bucket_tag_pairs



  # CALLBACKS
  
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

end
