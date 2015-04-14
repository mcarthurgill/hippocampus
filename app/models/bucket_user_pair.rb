  class BucketUserPair < ActiveRecord::Base
  attr_accessible :bucket_id, :phone_number, :name

  belongs_to :bucket
  belongs_to :user, :class_name => "User", :foreign_key => :phone_number, :primary_key => :phone

  after_save :update_bucket_visibility
  after_destroy :update_bucket_visibility

  # -- CALLBACKS

  def update_bucket_visibility
    self.bucket.update_visibility    
  end

  # -- CREATORS

  def self.create_with_bucket_id_and_phone_number_and_name(bid, pn, n="You", invited_by_user=nil)
    bup = BucketUserPair.find_or_initialize_by_bucket_id_and_phone_number(bid, pn)
    curr_user = bup.user

    if curr_user && bup.bucket.creator != curr_user
      curr_user.update_name(n)
    end

    if bup.new_record?
      bup.name = (curr_user.nil? || curr_user.no_name?) ? n : curr_user.name
      bup.save
      bup.delay.alert_if_collaborative(invited_by_user)
    end
    return bup
  end


  # -- UPDATE

  def self.update_all_for_user_name(u)
    bucket_user_pairs = BucketUserPair.where("phone_number = ?", u.phone)
    bucket_user_pairs.each do |bup|
      bup.update_name(u.name)
    end
  end

  def update_name(new_name)
    self.name = new_name
    self.save
  end

  # -- ACTIONS
  def alert_if_collaborative invited_by_user
    if invited_by_user
      message = "#{invited_by_user.name} invited you to collaborate on their #{self.bucket.first_name} thread in Hippocampus. Go to http://hppcmps.com/ and we'll show you how Hippocampus works so you can start remembering the things that matter."
      reason = "invite"
      if self.user
        message = "#{invited_by_user.name} invited you to collaborate on their #{self.bucket.first_name} thread in Hippocampus."  
        reason = "add_collaborator"
      end
      OutgoingMessage.send_text_to_number_with_message_and_reason(self.phone_number, message, reason)
    end
  end
end
