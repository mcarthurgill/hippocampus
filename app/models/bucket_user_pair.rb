  class BucketUserPair < ActiveRecord::Base


  attr_accessible :bucket_id, :phone_number, :name, :last_viewed, :unseen_items, :group_id

  belongs_to :bucket
  belongs_to :user, :class_name => "User", :foreign_key => :phone_number, :primary_key => :phone

  has_many :all_groups, :class_name => "Group", :foreign_key => "id", :primary_key => "group_id"

  after_save :update_bucket_visibility
  after_destroy :update_bucket_visibility

  scope :for_bucket_ids_and_phone, ->(bucket_ids, phone) { where(:bucket_id => bucket_ids, :phone_number => phone).includes(:bucket) }
  scope :for_phone_number, ->(phone) { where(:phone_number => phone) }
  scope :has_unseen_items, -> { where('unseen_items = ?', 'yes') }





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





  # -- DESTROY

  def self.destroy_for_phone_number_and_bucket pn, b
    bup = BucketUserPair.where("phone_number = ? AND bucket_id = ?", pn, b.id).first
    bup.destroy if bup
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

  def touch_as_viewed
    self.update_attributes(last_viewed: Time.now, unseen_items: 'no')
  end

  def mark_as_new_unseen
    self.update_attribute(:unseen_items, 'yes')
  end

  def alert_if_collaborative invited_by_user
    if invited_by_user
      message = "#{invited_by_user.name} invited you to collaborate on their #{self.bucket.first_name} collection in Hippocampus. Go to http://hppcmps.com/ and we'll show you how Hippocampus works so you can start remembering the things that matter."
      reason = "invite"
      if self.user
        message = "#{invited_by_user.name} invited you to collaborate on their #{self.bucket.first_name} collection in Hippocampus."  
        reason = "add_collaborator"
      end
      OutgoingMessage.send_text_to_number_with_message_and_reason(self.phone_number, message, reason)
    end
  end



  # -- ATTRIBUTES

  def group
    self.all_groups.for_user(self.user ? self.user.id : nil).first
  end


end
