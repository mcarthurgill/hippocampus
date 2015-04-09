class BucketUserPair < ActiveRecord::Base
  attr_accessible :bucket_id, :phone_number, :name

  belongs_to :bucket
  belongs_to :user, :class_name => "User", :foreign_key => :phone_number, :primary_key => :phone


  # -- CREATORS

  def self.create_with_bucket_id_and_phone_number_and_name(bid, pn, n="You")
    bup = BucketUserPair.find_or_initialize_by_bucket_id_and_phone_number(bid, pn)
    curr_user = bup.user

    if bup.new_record?
      bup.name = curr_user.no_name? ? n : curr_user.name
      bup.save
    end
    return bup
  end


  # -- UPDATE

  def self.update_all_for_user_name(u)
    bucket_user_pairs = BucketUserPair.where("phone_numer = ?", u.phone)
    bucket_user_pairs.each do |bup|
      bup.update_name(u.name)
    end
  end

  def update_name(new_name)
    self.name = new_name
    self.save
  end
end
