class Group < ActiveRecord::Base

  attr_accessible :group_name, :number_buckets, :user_id

  belongs_to :user

  has_many :bucket_user_pairs
  has_many :buckets, :through => :bucket_user_pairs

  scope :for_user, ->(uid) { where("user_id = ?", uid) }

end
