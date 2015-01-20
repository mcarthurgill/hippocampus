class Bucket < ActiveRecord::Base

  attr_accessible :description, :first_name, :items_count, :last_name, :user_id, :bucket_type

  # possible bucket_type: "Other", "Person", "Event", "Place", "Journal"


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs, dependent: :destroy
  has_many :items, :through => :bucket_item_pairs


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
  scope :journal_type, -> { where('bucket_type = ?', 'Journal') }


  # -- VALIDATIONS

  before_validation :strip_whitespace

  after_save :index_delayed

  before_destroy :remove_from_engine

  def before_save
    self.items_count = self.items.count
    self.first_name = (self.first_name && self.first_name.length > 0) ? self.first_name.strip : self.first_name
    self.last_name = (self.last_name && self.last_name.length > 0) ? self.last_name.strip : self.last_name
  end

  def increment_count
    self.items_count = self.items.count
    self.save!
  end

  def strip_whitespace
    self.description = self.description ? self.description.strip : nil
    self.first_name = self.first_name ? self.first_name.strip : nil
    self.last_name = self.last_name ? self.last_name.strip : nil
    self.bucket_type = self.bucket_type ? self.bucket_type.strip : nil
  end

  def self.find_or_create_for_addon_and_user(addon, user)  
    bucket = Bucket.for_addon_and_user(addon, user)

    if bucket.nil?
      b = Bucket.create(attrs_hash)
      return b
    end
    return bucket
  end

  def self.for_addon_and_user(addon, user)
    attrs_hash = addon.params_to_create_bucket_for_user(user, false)
    Bucket.where(attrs_hash).first
  end

  # -- HELPERS

  def display_name
    return self.first_name   # ( (self.first_name ? self.first_name : '') + (self.last_name ? (" " + self.last_name) : '') ).strip
  end

  def self.bucket_types
    return ["Other", "Person", "Event", "Place"]
  end

  def belongs_to_user?(u)
    self.user == u
  end

  def created_by_addon?
    !Bucket.bucket_types.include?(self.bucket_type)
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
    client.create_or_update_documents(engine_slug, document_slug, [
      {:external_id => self.id, :fields => [
        {:name => 'first_name', :value => self.first_name, :type => 'string'},
        {:name => 'items_count', :value => self.items_count, :type => 'integer'},
        {:name => 'user_id', :value => self.user_id, :type => 'integer'},
        {:name => 'bucket_type', :value => self.bucket_type, :type => 'string'},
        {:name => 'bucket_id', :value => self.id, :type => 'integer'},
      ]}
    ])
  end

  def remove_from_engine
    client = Swiftype::Client.new
    # The automatically created engine has a slug of 'engine'
    engine_slug = 'engine'
    document_slug = 'buckets'
    client.destroy_document(engine_slug, document_slug, self.id)
  end


end
