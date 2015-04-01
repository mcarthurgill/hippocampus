class BucketUserPair < ActiveRecord::Base
  attr_accessible :bucket_id, :phone_number

  belongs_to :bucket
  belongs_to :user, :class_name => "User", :foreign_key => :phone_number, :primary_key => :phone

  # -- CREATORS

  def self.create_with_bucket_id_and_phone_number(bid, pn)
    bup = BucketUserPair.find_or_initialize_by_bucket_id_and_phone_number(bid, pn)
    bup.save if bup.new_object?
    return bup
  end
end
