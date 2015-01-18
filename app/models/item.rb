class Item < ActiveRecord::Base
  attr_accessible :media_urls, :media_content_types, :message, :bucket_id, :user_id, :item_type, :reminder_date, :status, :input_method

  serialize :media_content_types, Array
  serialize :media_urls, Array

  # types: note, yearly, monthly, weekly, daily


  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs, dependent: :destroy
  has_many :buckets, :through => :bucket_item_pairs
  # belongs_to :bucket

  has_many :sms
  has_many :emails

  # -- SCOPES

  scope :outstanding, -> { where("status = ?", "outstanding").includes(:user) } 
  scope :assigned, -> { where("status = ?", "assigned").includes(:user) } 
  scope :notes_for_today, -> { where("reminder_date = ? AND item_type = ?", Date.today, "note").includes(:user) } 
  scope :daily, -> { where("item_type = ?", "daily").includes(:user) } 
  scope :weekly, -> { where("item_type = ?", "weekly").includes(:user) } 
  scope :monthly, -> { where("item_type = ?", "monthly").includes(:user) } 
  scope :yearly, -> { where("item_type = ?", "yearly").includes(:user) } 
  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime) }
  scope :by_date, -> { order("created_at DESC") }
  
  # -- CALLBACKS

  before_validation :strip_whitespace
  before_save :check_status

  after_save :index_delayed

  before_destroy :remove_from_engine


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
    i.media_urls = sms.MediaUrls
    i.media_content_types = sms.MediaContentTypes
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

  def self.create_from_api_endpoint(params)
    i = Item.new
    i.user = User.validated_with_id_addon_and_token(params[:user][:id], params[:addon], params[:user][:token]) 
    return nil if !i.user

    i.message = params[:message]
    i.input_method = params[:addon]
    i.item_type = 'note'
    i.status = 'assigned'
    
    b = Item.determine_bucket_for_addon_and_user(params[:addon], i.user, params[:user][:bucket_id])
    i.bucket_id = b.id

    if i.user && i.message && i.message.length > 0
      i.save!
      i.add_to_bucket(b)
      return i
    end
    return nil
  end




  # -- DESTROY

  def delete
    self.update_attribute(:status, 'deleted')
  end




  # -- CLOUDINARY

  def upload_main_asset(file)
    public_id = "item_#{Time.now.to_f}_#{self.user_id}"
    url = self.upload_image_to_cloudinary(file, public_id, 'jpg')
    if url && url.length > 0
      return self.add_media_url(url)
    end
  end

  def upload_image_to_cloudinary(file, public_id, format)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format)
    return data['url']
  end

  def add_media_url url
    if !self.media_urls
      self.media_urls = []
    end
    self.media_urls << url
    self.save!
    return self.media_urls
  end



  # -- ATTRIBUTES

  def deleted?
    return self.status == 'deleted'
  end

  def outstanding?
    return self.status == 'outstanding'
  end

  def assigned?
    return self.status == 'assigned'
  end

  # -- ACTIONS

  def update_outstanding
    if self.has_buckets?
      self.update_attribute(:status, 'assigned')
    else
      self.update_attribute(:status, 'outstanding')
    end
  end

  def add_to_bucket b
    BucketItemPair.with_or_create_with_bucket_id_and_item_id(b.id, self.id)
  end




  
  # -- HELPERS

  def has_media?
    return (self.media_urls && self.media_urls.count > 0)
  end

  def buckets_string
    s = ''
    self.buckets.each do |b|
      s = "#{s} #{b.display_name}"
    end
    return s
  end

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
      return self.created_at.strftime("%A, %B %-d")
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

  def self.determine_bucket_for_addon_and_user(addon_name, user, bid)
    if bid && bid.length > 0
      b = Bucket.find(bid)
      if b && b.belongs_to_user?(user)
        return b
      end
    end
    return Bucket.create_for_addon_and_user(addon_name, user)
  end


  

  # -- REMINDERS

  def self.remind_about_events
    self.remind_about_notes_for_today
    self.remind_about_daily_items
    self.remind_about_weekly_items
    self.remind_about_monthly_items
    self.remind_about_yearly_items
  end

  def self.remind_about_notes_for_today
    items = Item.notes_for_today
    items.each do |i|
      message = "Your Hippocampus reminder for today:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
    end
  end

  def self.remind_about_daily_items
    items = Item.daily
    items.each do |i|
      message = "Your daily Hippocampus reminder:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
    end
  end

  def self.remind_about_weekly_items
    items = Item.get_weekly_items_for_today
    items.each do |i|
      message = "Your weekly Hippocampus reminder:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
    end
  end

  def self.get_weekly_items_for_today
    epoch = Date.parse("1/1/1970")
    days_mod = (Date.today - epoch).to_i%7
    items = []

    Item.weekly.each do |i|
      if (i.reminder_date - epoch).to_i%7 == days_mod
        items << i
      end
    end
    return items
  end

  def self.remind_about_monthly_items
    date_as_string = Date.today.strftime("%d/%m/%Y")
    items = Item.where("strftime('%d', reminder_date) = ?", Date.parse(date_as_string).strftime('%d')).monthly

    items.each do |i|
      message = "Your monthly Hippocampus reminder:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
    end
  end

  def self.remind_about_yearly_items
    date_as_string = Date.today.strftime("%d/%m/%Y")
    items = Item.where("strftime('%d', reminder_date) = ? AND strftime('%m', reminder_date) = ?", Date.parse(date_as_string).strftime('%d'), Date.parse(date_as_string).strftime('%m')).yearly
    
    items.each do |i|
      message = "Your yearly Hippocampus reminder:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
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
    document_slug = 'items'

    if self.deleted?
      self.remove_from_engine
    else
      # create Documents within the DocumentType
      client.create_or_update_documents(engine_slug, document_slug, [
        {:external_id => self.id, :fields => [
          {:name => 'message', :value => self.message, :type => 'string'},
          {:name => 'user_id', :value => self.user_id, :type => 'integer'},
          {:name => 'item_type', :value => self.item_type, :type => 'string'},
          {:name => 'buckets_string', :value => self.buckets_string, :type => 'string'},
          {:name => 'item_id', :value => self.id, :type => 'integer'},
        ]}
      ])
    end
  end

  def remove_from_engine
    client = Swiftype::Client.new
    # The automatically created engine has a slug of 'engine'
    engine_slug = 'engine'
    document_slug = 'items'
    client.destroy_document(engine_slug, document_slug, self.id)
  end

end
