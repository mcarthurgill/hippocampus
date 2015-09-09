class Bucket < ActiveRecord::Base 

  include Formatting

  attr_accessible :authorized_user_ids, :cached_item_message, :description, :first_name, :items_count, :last_name, :device_timestamp, :local_key, :object_type, :user_id, :bucket_type, :updated_at, :visibility, :creation_reason

  serialize :authorized_user_ids, Array

  # possible bucket_type: "Other", "Person", "Event", "Place"


  # -- RELATIONSHIPS

  has_many :bucket_user_pairs
  has_many :groups, :through => :bucket_user_pairs

  has_many :users, :through => :bucket_user_pairs

  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  has_many :bucket_item_pairs, dependent: :destroy

  has_many :items, :through => :bucket_item_pairs

  has_many :contact_cards


  # -- SCOPES

  scope :above, ->(time) { where('"buckets"."updated_at" > ?', Time.at(time.to_i).to_datetime).order('id ASC') }
  scope :by_first_name, -> { order("first_name ASC") }
  scope :recent_first, -> { order("id DESC") }
  scope :excluding_pairs_for_item_id, ->(iid) { where( (BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id).count > 0 ? '"buckets"."id" NOT IN (?)' : ''), BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id)) }
  scope :recent_for_user_id, ->(uid) { where('"buckets"."id" IN (?)', BucketItemPair.where('"bucket_item_pairs"."bucket_id" IN (?)', User.find(uid).buckets.pluck(:id)).order('updated_at DESC').limit(8).pluck(:bucket_id)) }
  scope :for_user_and_creation_reason, ->(uid, r) { where("id IN (?) AND creation_reason = ?", User.find(uid).buckets.pluck(:id), r) }

  scope :other_type, -> { where('bucket_type = ?', 'Other') }
  scope :person_type, -> { where('bucket_type = ?', 'Person') }
  scope :event_type, -> { where('bucket_type = ?', 'Event') }
  scope :place_type, -> { where('bucket_type = ?', 'Place') }




  # -- VALIDATIONS

  validates :local_key, :uniqueness => true

  after_initialize :default_values
  def default_values
    self.bucket_type ||= 'Other'
  end

  before_validation :strip_whitespace

  before_destroy :update_items_before_destroy

  def before_save
    self.items_count = self.items.count
    self.first_name = (self.first_name && self.first_name.length > 0) ? self.first_name.strip : self.first_name
    self.last_name = (self.last_name && self.last_name.length > 0) ? self.last_name.strip : self.last_name
  end

  before_save :set_defaults
  def set_defaults
    self.device_timestamp ||= Time.now.to_f
    self.local_key ||= "bucket-#{self.device_timestamp}-#{self.user_id}" if self.device_timestamp && self.user_id
  end

  def update_caches
    self.assign_count
    self.assign_cached_item_message
    self.save!
  end

  def update_bucket_caches
    cur_vis = "#{self.visibility}"

    self.assign_visibility
    self.assign_authorized_user_ids
    self.save!
    
    if cur_vis != self.visibility
      self.delay.update_items_indexes
    end
  end

  def assign_authorized_user_ids
    self.authorized_user_ids = self.users.pluck(:id)
  end

  def update_count
    self.assign_count
    self.save!
  end

  def assign_count
    self.items_count = self.items.not_deleted.count
  end

  def update_cached_item_message
    self.assign_cached_item_message
    self.save!
  end

  def assign_cached_item_message
    string = self.items.not_deleted.by_date.pluck(:message).first
    string = string[0...200] if string
    self.cached_item_message = string
  end

  def strip_whitespace
    self.description = self.description ? self.description.strip : nil
    self.first_name = self.first_name ? self.first_name.strip : nil
    self.last_name = self.last_name ? self.last_name.strip : nil
    self.bucket_type = self.bucket_type ? self.bucket_type.strip : nil
  end


  # -- CREATORS

  def update_items_before_destroy
    self.delay.remove_from_items
  end

  def remove_from_items
    self.items.not_deleted.each do |i|
      bip = BucketItemPair.find_by_bucket_id_and_item_id(self.id, i.id)
      if bip
        bip.destroy
        i.update_deleted
      end
    end  
  end

  after_create :update_user_buckets_count
  def update_user_buckets_count
    self.creator.update_buckets_count
  end






  # -- HELPERS

  def self.all_items_bucket
    return { id: 0, first_name: 'All Thoughts', object_type: 'all-thoughts' }
  end

  def display_name
    return self.first_name   # ( (self.first_name ? self.first_name : '') + (self.last_name ? (" " + self.last_name) : '') ).strip
  end

  def self.bucket_types
    return ["Other", "Person", "Event", "Place"]
  end

  def belongs_to_user?(u)
    self.users.include?(u)
  end

  def update_items_with_new_bucket_name
    self.items.each do |i|
      i.delay.update_buckets_string
    end
  end

  def media_urls
    self.items.not_deleted.order("items.created_at DESC").pluck(:media_urls).flatten
  end

  def collaborative?
    return self.users.count > 1
  end

  def user_ids_array
    arr = [self.user_id]
    self.users.each do |u|
      arr << u.id
    end
    return arr.uniq
  end

  def group_for_user u
    return self.groups.where('"bucket_user_pairs"."phone_number" = ?', u.phone).first if u
  end





  # -- ACTIONS

  def viewed_by_user_id uid
    u = uid ? User.find_by_id(uid) : nil
    if u
      u.bucket_user_pairs.where('bucket_id = ?', self.id).each do |bucket_user_pair|
        bucket_user_pair.touch_as_viewed
      end
    end
  end

  def mark_collaborators_as_unseen bucket_item_pair
    self.bucket_user_pairs.where('phone_number != ? AND (last_viewed IS NULL OR last_viewed < ?)', bucket_item_pair.item.user.phone, bucket_item_pair.created_at).each do |bucket_user_pair|
      bucket_user_pair.mark_as_new_unseen if bucket_user_pair.user.id != bucket_item_pair.item.user.id
    end
  end

  def add_collaborators_from_contacts_with_calling_code(contacts_array, calling_code, invited_by_user)
    contacts_array.each do |contact|
      if contact[:phones] && contact[:phones].count > 0
        contact[:phones].each do |p|
          self.add_user_from_phone_and_name(format_phone(p, calling_code), contact[:name], invited_by_user)
        end
      end
    end
  end

  def add_user_from_phone_and_name(phone_number, name, invited_by_user)
    self.add_user(User.find_by_phone(phone_number), name, phone_number, invited_by_user)
  end

  def add_user u, name="You", phone_number=nil, invited_by_user=nil
    if u && !self.belongs_to_user?(u)
      BucketUserPair.create_with_bucket_id_and_phone_number_and_name(self.id, u.phone, name, invited_by_user)
    elsif u.nil? && phone_number
      BucketUserPair.create_with_bucket_id_and_phone_number_and_name(self.id, phone_number, name, invited_by_user)
    end
  end

  def add_contact_card params
    contact_card = ContactCard.new
    contact_card.contact_info = params[:contact_info].to_s
    contact_card.bucket_id = self.id
    if params.has_key?(:file) && params[:file]
      contact_card.upload_main_asset(params[:file])
    end
    contact_card.save!
    return contact_card
  end

  def remove_user u
    BucketUserPair.destroy_for_phone_number_and_bucket(u.phone, self)
  end

  def add_to_group_with_id_for_user gid, u
    if gid && u
      bup = BucketUserPair.find_by_bucket_id_and_user_id(self.id, u.id)
      bup.update_attribute(:group_id, gid) if bup
    end
  end


  def assign_visibility
    self.visibility = (self.users.count > 1 ? "collaborative" : "private")
  end

  def update_visibility
    self.assign_visibility
    self.save!
  end

  def update_items_indexes
    self.items.each do |i|
      i.index_delayed
    end
  end


end
