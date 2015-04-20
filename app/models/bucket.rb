class Bucket < ActiveRecord::Base

  include Formatting

  attr_accessible :description, :first_name, :items_count, :last_name, :user_id, :bucket_type, :updated_at, :visibility

  # possible bucket_type: "Other", "Person", "Event", "Place"


  # -- RELATIONSHIPS

  has_many :bucket_user_pairs
  has_many :users, :through => :bucket_user_pairs
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"
  has_many :bucket_item_pairs, dependent: :destroy
  has_many :items, :through => :bucket_item_pairs
  has_many :contact_cards


  # -- SCOPES

  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime).order('id ASC') }
  scope :by_first_name, -> { order("first_name ASC") }
  scope :recent_first, -> { order("id DESC") }
  scope :excluding_pairs_for_item_id, ->(iid) { where( (BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id).count > 0 ? '"buckets"."id" NOT IN (?)' : ''), BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id)) }
  scope :recent_for_user_id, ->(uid) { where('"buckets"."id" IN (?)', BucketItemPair.where('"bucket_item_pairs"."bucket_id" IN (?)', User.find(uid).buckets.pluck(:id)).order('updated_at DESC').limit(8).pluck(:bucket_id)) }

  scope :other_type, -> { where('bucket_type = ?', 'Other') }
  scope :person_type, -> { where('bucket_type = ?', 'Person') }
  scope :event_type, -> { where('bucket_type = ?', 'Event') }
  scope :place_type, -> { where('bucket_type = ?', 'Place') }




  # -- VALIDATIONS

  before_validation :strip_whitespace

  after_save :index_delayed

  before_destroy :remove_from_engine, :update_items_before_destroy

  def before_save
    self.items_count = self.items.count
    self.first_name = (self.first_name && self.first_name.length > 0) ? self.first_name.strip : self.first_name
    self.last_name = (self.last_name && self.last_name.length > 0) ? self.last_name.strip : self.last_name
  end

  def update_count
    self.items_count = self.items.not_deleted.count
    self.save!
  end

  def strip_whitespace
    self.description = self.description ? self.description.strip : nil
    self.first_name = self.first_name ? self.first_name.strip : nil
    self.last_name = self.last_name ? self.last_name.strip : nil
    self.bucket_type = self.bucket_type ? self.bucket_type.strip : nil
  end


  # -- CREATORS

  def self.create_for_addon_and_user(addon, user)  
    attrs_hash = addon.params_to_create_bucket_for_user(user)
    return Bucket.create(attrs_hash)
  end

  def self.create_from_setup_question params
    u = User.find(params[:auth][:uid])
    b = Bucket.new
    b.first_name = params[:setup_question][:response]
    b.bucket_type = "Person"
    b.visibility = "private"
    b.save
    b.add_user(u)
    return b
  end

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


  # -- ACTIONS

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

  def remove_user u
    BucketUserPair.destroy_for_phone_number_and_bucket(u.phone, self)
  end

  def update_visibility
    self.visibility = (self.users.count > 1 ? "collaborative" : "private")
    self.save!

    self.index_delayed
    self.delay.update_items_indexes
  end

  def update_items_indexes
    self.items.each do |i|
      i.index_delayed
    end
  end






  #  swiftype

  def index_delayed
    self.delay.index
  end

  def index
    client = Swiftype::Client.new

    # The automatically created engine has a slug of 'engine'
    engine_slug = 'engine'
    document_slug = 'buckets'

    # create Documents within the DocumentType
    begin
      client.create_or_update_document(engine_slug, document_slug,
        {:external_id => self.id, :fields => [
          {:name => 'first_name', :value => self.first_name, :type => 'string'},
          {:name => 'items_count', :value => self.items_count, :type => 'integer'},
          {:name => 'user_id', :value => self.user_id, :type => 'integer'},
          {:name => 'available_to', :value => self.user_ids_array, :type => 'integer'},
          {:name => 'bucket_type', :value => self.bucket_type, :type => 'string'},
          {:name => 'bucket_id', :value => self.id, :type => 'integer'},
          {:name => 'visibility', :value => self.visibility, :type => 'string'},
          {:name => 'created_at_server', :value => self.created_at, :type => 'string'},
          {:name => 'updated_at_server', :value => self.updated_at, :type => 'string'},
        ]}
      )
    rescue Exception => e
      puts 'rescued a swiftype exception!'
    end
  end

  def remove_from_engine
    client = Swiftype::Client.new
    # The automatically created engine has a slug of 'engine'
    engine_slug = 'engine'
    document_slug = 'buckets'
    begin
      client.destroy_document(engine_slug, document_slug, self.id)
    rescue Exception => e
      puts 'rescued a swiftype exception!'
    end
  end


end
