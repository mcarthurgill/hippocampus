class Group < ActiveRecord::Base

  attr_accessible :group_name, :number_buckets, :user_id

  belongs_to :user

  has_many :all_bucket_user_pairs, :class_name => "BucketUserPair", :primary_key => "group_name", :foreign_key => "group_name"
  has_many :all_buckets, :through => :all_bucket_user_pairs, :source => :bucket #:class_name => "Bucket", :foreign_key => "bucket_id", :primary_key => "id"

  scope :for_user, ->(uid) { where("user_id = ?", uid) }

  def buckets
    self.all_buckets.where('"bucket_user_pairs"."phone_number" = ?', self.user.phone)
  end

end
