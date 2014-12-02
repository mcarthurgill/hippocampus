class Item < ActiveRecord::Base

  attr_accessible :message, :bucket_id, :user_id, :item_type, :reminder_date, :status, :input_method


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs
  #has_many :buckets, :through => :bucket_item_pairs
  belongs_to :bucket

  has_many :sms
  has_many :emails


  # -- SCOPES

  scope :outstanding, -> { where("status = ?", "outstanding").includes(:user) } 
  scope :assigned, -> { where("status = ?", "assigned").includes(:user) } 
  scope :events_for_today, -> { where("reminder_date = ?", Date.today).includes(:user) } 
  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime) }


  # -- VALIDATIONS

  before_validation :strip_whitespace

  def strip_whitespace
    self.message = self.message ? self.message.strip : nil
    self.item_type = self.item_type ? self.item_type.strip : nil
    self.status = self.status ? self.status.strip : nil
    self.input_method = self.input_method ? self.input_method.strip : nil
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
    if self.outstanding? && self.bucket_id
      self.update_attribute(:status, 'assigned')
    end
  end
  
end
