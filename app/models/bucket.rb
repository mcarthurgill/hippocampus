class Bucket < ActiveRecord::Base 

  include Formatting

  attr_accessible :authorized_user_ids, :cached_item_message, :description, :first_name, :items_count, :last_name, :device_timestamp, :local_key, :object_type, :relation_level, :tags_array, :user_id, :bucket_type, :updated_at, :visibility, :creation_reason

  serialize :authorized_user_ids, Array
  serialize :tags_array, Array

  # possible bucket_type: "Other", "Person", "Event", "Place"


  # -- RELATIONSHIPS

  has_many :bucket_user_pairs
  has_many :groups, :through => :bucket_user_pairs

  has_many :users, :through => :bucket_user_pairs

  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"

  has_many :bucket_item_pairs, dependent: :destroy

  has_many :items, :through => :bucket_item_pairs

  has_many :contact_cards

  has_many :bucket_tag_pairs
  has_many :tags, through: :bucket_tag_pairs


  # -- SCOPES

  scope :above, ->(time) { where('"buckets"."updated_at" > ?', Time.at(time.to_i).to_datetime).order('id ASC') }
  scope :by_first_name, -> { order("LOWER(first_name) ASC") }
  scope :recent_first, -> { order("id DESC") }
  scope :excluding_pairs_for_item_id, ->(iid) { where( (BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id).count > 0 ? '"buckets"."id" NOT IN (?)' : ''), BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id)) }
  scope :recent_for_user_id, ->(uid) { where('"buckets"."id" IN (?)', BucketItemPair.where('"bucket_item_pairs"."bucket_id" IN (?)', User.find(uid).buckets.pluck(:id)).order('updated_at DESC').limit(8).pluck(:bucket_id)) }
  scope :for_user_and_creation_reason, ->(uid, r) { where("id IN (?) AND creation_reason = ?", User.find(uid).buckets.pluck(:id), r) }
  scope :for_page_with_limit, ->(page, lim) { offset(page*lim).limit(lim) }
  
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

  before_save :make_array_ids_integers
  def make_array_ids_integers
    if self.authorized_user_ids
      temp_arr = []
      self.authorized_user_ids.each do |auid|
        temp_arr << auid.to_i
      end
      self.authorized_user_ids = temp_arr
    end
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

  def update_tags_array
    self.assign_tags_array
    self.save!
  end

  def assign_tags_array
    self.tags_array = self.id ? self.tags.as_json : []
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
    string = self.items.not_deleted.by_date.where("message IS NOT NULL AND message <> ''").pluck(:message).first
    string = string[0...200] if string
    self.cached_item_message = string
  end

  def strip_whitespace
    self.description = self.description ? self.description.strip : nil
    self.first_name = self.first_name ? self.first_name.strip : nil
    self.last_name = self.last_name ? self.last_name.strip : nil
    self.bucket_type = self.bucket_type ? self.bucket_type.strip : nil
  end

  after_save :push
  def push
    begin
      Pusher.trigger(self.users_array_for_push, 'bucket-save', self.as_json(methods: [:html_as_string])) if self.users_array_for_push.count > 0
    rescue Pusher::Error => e
    end
  end

  def users_array_for_push
    arr = []
    self.users.each do |u|
      arr << u.push_channel
    end
    return arr
  end

  def html_as_string
    return self.render_anywhere('shared/buckets/bucket_preview', {bucket: self})
  end
  
  def render_anywhere(partial, assigns = {})
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
    view.extend ApplicationHelper
    view.render(partial: partial, locals: assigns)
  end

  after_save :index_delayed
  before_destroy :remove_from_engine




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

  def deleted?
    return false
  end

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

  def update_items_with_new_collaborators
    self.items.each do |i|
      i.delay.save!
    end
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

  def user_has_access? u
    return self.authorized_user_ids.include?(u.id)
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

  def add_collaborators_from_contacts_with_calling_code(contacts_array, calling_code="1", invited_by_user)
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
    contact_card.assign_attributes(params)
    contact_card.bucket_id = self.id
    if params.has_key?(:file) && params[:file]
      contact_card.upload_main_asset(params[:file])
    end
    contact_card.save!
    return contact_card
  end

  def remove_user u
    self.remove_user_with_phone_number(u.phone)
  end

  def remove_user_with_phone_number phone
    BucketUserPair.destroy_for_phone_number_and_bucket(phone, self)
  end

  def add_to_group_with_id_for_user gid, u
    if gid && u
      bup = BucketUserPair.find_by_bucket_id_and_user_id(self.id, u.id)
      bup.update_attribute(:group_id, gid) if bup
    end
  end

  def update_tags_with_local_keys_and_user local_keys, u
    all_local_keys = self.tag_local_keys_without_user_permission(u)
    if local_keys && local_keys.count > 0
      local_keys.each do |lk|
        all_local_keys << lk
      end
    end
    return self.update_tags_with_local_keys(all_local_keys.uniq)
  end

  def update_tags_with_local_keys local_keys
    if local_keys && local_keys.count > 0
      self.tags = Tag.find_all_by_local_key(local_keys)
    else
      self.tags = []
    end
    self.save!
    self.update_tags_array if self
    self.tags.each do |tag|
      tag.delay.update_number_buckets if tag
    end
    return true
  end

  def tag_local_keys_without_user_permission u
    temp = []
    self.tags.each do |t|
      temp << t.local_key if !t.user_has_access?(u)
    end
    return temp
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

  def set_relation_level
    new_level = 'past'
    if self.items.where('(item_type = ? OR item_type = ? OR item_type = ?) OR (item_type = ? AND reminder_date IS NOT NULL AND reminder_date < ?)', 'daily', 'weekly', 'monthly', 'once', 1.month.from_now.to_date).count > 0
      new_level = 'future'
    elsif self.items.since_time_ago(3.weeks.ago).count > 0
      new_level = 'recent'
    end
    self.update_attribute(:relation_level, new_level) if new_level != self.relation_level
  end





  # algolia

  include AlgoliaSearch

  algoliasearch unless: :deleted? do
    # all attributes + extra_attr will be sent
    # add_attribute :user_ids_array, :_geoloc, :date
  end

  def index_delayed
    self.delay.index
  end

  def index
    # ALGOLIA!
    self.index!
  end

  def remove_from_engine
    # ALGOLIA!
    self.remove_from_index!
  end


end
