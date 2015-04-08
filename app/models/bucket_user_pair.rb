class BucketUserPair < ActiveRecord::Base
  attr_accessible :bucket_id, :phone_number, :name

  belongs_to :bucket
  belongs_to :user, :class_name => "User", :foreign_key => :phone_number, :primary_key => :phone

  # -- CREATORS

  def self.create_with_bucket_id_and_phone_number_and_name(bid, pn, n)
    bup = BucketUserPair.find_or_initialize_by_bucket_id_and_phone_number(bid, pn)
    if bup.new_record? || bup.name != n
      bup.name = n
      bup.save
    end
    return bup
  end
end
