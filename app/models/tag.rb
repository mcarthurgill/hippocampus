class Tag < ActiveRecord::Base

  attr_accessible :local_key, :number_buckets, :object_type, :tag_name, :user_id

  belongs_to :user

  has_many :bucket_tag_pairs
  has_many :buckets, through: :bucket_tag_pairs


end
