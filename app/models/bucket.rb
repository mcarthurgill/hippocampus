class Bucket < ActiveRecord::Base

  attr_accessible :description, :first_name, :last_name, :user_id, :bucket_type

  # possible bucket_type: "Other", "Person", "Event", "Place"


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs
  has_many :items, :through => :bucket_item_pairs


  # -- SCOPES

  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime).order('id ASC') }
  scope :by_first_name, -> { order("first_name ASC") }
  scope :excluding_pairs_for_item_id, ->(iid) { where( (BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id).count > 0 ? '"buckets"."id" NOT IN (?)' : ''), BucketItemPair.where('item_id = ?', iid).pluck(:bucket_id)) }
  scope :recent_for_user_id, ->(uid) { where('"buckets"."id" IN (?)', BucketItemPair.where('"bucket_item_pairs"."bucket_id" IN (?)', User.find(uid).buckets.pluck(:id)).order('updated_at DESC').limit(8).pluck(:bucket_id)) }


  # -- VALIDATIONS

  before_validation :strip_whitespace

  def strip_whitespace
    self.description = self.description ? self.description.strip : nil
    self.first_name = self.first_name ? self.first_name.strip : nil
    self.last_name = self.last_name ? self.last_name.strip : nil
    self.bucket_type = self.bucket_type ? self.bucket_type.strip : nil
  end


  # -- HELPERS

  def display_name
    return ( (self.first_name ? self.first_name : '') + (self.last_name ? (" " + self.last_name) : '') ).strip
  end

  def self.bucket_types
    return ["Other", "Person", "Event", "Place"]
  end


end
