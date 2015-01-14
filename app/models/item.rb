class Item < ActiveRecord::Base

  attr_accessible :message, :bucket_id, :user_id, :item_type, :reminder_date, :status, :input_method

  # types: note, yearly, monthly, weekly, daily


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs
  has_many :buckets, :through => :bucket_item_pairs
  # belongs_to :bucket

  has_many :sms
  has_many :emails

  # -- SCOPES

  scope :outstanding, -> { where("status = ?", "outstanding").includes(:user) } 
  scope :assigned, -> { where("status = ?", "assigned").includes(:user) } 
  scope :events_for_today, -> { where("reminder_date = ?", Date.today).includes(:user) } 
  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime) }
  scope :by_date, -> { order("created_at DESC") }
  
  # -- CALLBACKS

  before_validation :strip_whitespace
  before_save :check_status

  def strip_whitespace
    self.message = self.message ? self.message.strip : nil
    self.item_type = self.item_type ? self.item_type.strip : nil
    self.status = self.status ? self.status.strip : nil
    self.input_method = self.input_method ? self.input_method.strip : nil
  end

  def check_status
    self.status = "outstanding" if !self.has_buckets?
  end

  # -- SETTERS

  def self.create_with_sms(sms)
    i = Item.new
    i.message = sms.Body
    i.user = User.with_phone_number(sms.From)
    i.item_type = 'note'
    i.status = 'outstanding'
    i.input_method = 'sms'
    i.save!
    return i
  end

  def self.create_with_email(email)
    i = Item.new
    i.message = email.parsed_text
    i.user = User.with_email(email.From)
    i.item_type = 'note'
    i.status = 'outstanding'
    i.input_method = 'email'
    i.save!
    return i
  end

  # -- DESTROY

  def delete
    self.update_attribute(:status, 'deleted')
  end

  # -- ATTRIBUTES

  def outstanding?
    return self.status == 'outstanding'
  end

  def assigned?
    return self.status == 'assigned'
  end

  # -- ACTIONS

  def update_outstanding
    if self.outstanding? && self.has_buckets?
      self.update_attribute(:status, 'assigned')
    end
  end

  def add_to_bucket b
    BucketItemPair.with_or_create_with_bucket_id_and_item_id(b.id, self.id)
  end
  
  # -- HELPERS

  def has_buckets?
    return self.buckets.count > 0
  end

  def formatted_reminder_date
    self.reminder_date.strftime("%B %e, %Y") if self.reminder_date
  end

  def friendly_time
    if self.created_at > 7.days.ago
      return self.created_at.strftime("%A")
    elsif self.created_at > 11.months.ago
      return self.created_at.strftime("%B %-d (%A)")
    else
      return self.created_at.strftime("%B %-d, %Y")
    end
  end

  def created_at_central_time
    self.created_at - 6.hours
  end

  def self.item_types
    return ['note', 'yearly', 'monthly', 'weekly', 'daily']
  end

  # def display_bucket_name
  #   self.bucket ? self.bucket.display_name : "Not Assigned"
  # end
  
end
