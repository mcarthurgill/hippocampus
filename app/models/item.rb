class Item < ActiveRecord::Base

  attr_accessible :buckets_string, :device_request_timestamp, :device_timestamp, :latitude, :longitude, :links, :media_urls, :media_content_types, :message, :bucket_id, :user_id, :item_type, :reminder_date, :status, :input_method

  serialize :media_content_types, Array
  serialize :media_urls, Array
  serialize :links, Array

  # types: once, yearly, monthly, weekly, daily





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
  scope :not_deleted, -> { where("status != ?", "deleted") }
  scope :notes_for_today, -> { where("reminder_date = ? AND item_type = ?", Time.zone.now.to_date, "once").includes(:user) } 
  scope :daily, -> { where("item_type = ?", "daily").includes(:user) } 
  scope :weekly, -> { where("item_type = ?", "weekly").includes(:user) } 
  scope :monthly, -> { where("item_type = ?", "monthly").includes(:user) } 
  scope :yearly, -> { where("item_type = ?", "yearly").includes(:user) } 
  scope :above, ->(time) { where("updated_at > ?", Time.at(time.to_i).to_datetime) }
  scope :by_date, -> { order("created_at DESC") }
  scope :newest_last, -> { order("created_at ASC") }
  scope :with_reminder, -> { where("reminder_date IS NOT NULL") }
  scope :last_24_hours, -> { where("created_at > ? AND created_at < ?", 24.hours.ago, Time.now) }
  scope :with_long_lat_and_radius, ->(long, lat, rad) { where("((longitude - ?)^2 + (latitude - ?)^2) <= ?", long, lat, rad) }
  scope :within_bounds, ->(max_long, min_long, max_lat, min_lat) { where("longitude <= ? AND longitude >= ? AND latitude <= ? AND latitude >= ?", max_long, min_long, max_lat, min_lat) }
  




  # -- CALLBACKS

  before_validation :strip_whitespace
  def strip_whitespace
    self.message = self.message ? self.message.strip : nil
    self.item_type = self.item_type ? self.item_type.strip : nil
    self.status = self.status ? self.status.strip : nil
    self.input_method = self.input_method ? self.input_method.strip : nil
  end

  before_save :check_status
  def check_status
    self.status = "outstanding" if ( !self.deleted? && !self.has_buckets? )
    self.buckets_string = self.description_string
  end

  after_create :update_user_items_count
  def update_user_items_count
    self.user.delay.update_items_count
  end

  before_create :check_for_and_set_date

  before_save :extract_links

  after_save :index_delayed

  before_destroy :remove_from_engine





  # -- SETTERS

  def self.create_with_sms(sms)
    i = Item.new
    i.message = sms.Body
    i.user = User.with_phone_number(sms.From)
    i.upload_media(sms.MediaUrls)
    i.media_content_types = sms.MediaContentTypes
    i.item_type = 'once'
    i.status = 'outstanding'
    i.input_method = 'sms'
    i.save!
    return i
  end

  def self.create_with_email(email)
    i = Item.new
    i.message = email.parsed_text
    i.user = User.with_email(email.From)
    i.item_type = 'once'
    i.status = 'outstanding'
    i.input_method = 'email'
    i.save!
    return i
  end

  def self.create_from_api_endpoint(params, user, addon)
    i = Item.new
    i.user = user
    return nil if !i.user || !addon

    i.message = params["message"]
    i.input_method = params["addon"]
    i.item_type = 'once'
    i.status = 'assigned'
    bucket = Bucket.find(params["user"]["bucket_id"])
    i.bucket_id = bucket.id

    if i.user && i.message && i.message.length > 0
      i.save!
      i.add_to_bucket(bucket)
      return i
    end
    return nil
  end

  def self.create_from_contact_card(contact_card)
    i = Item.new
    i.user = contact_card.bucket.creator
    i.message = "Created from the notes section in your phone book: \n\n" + contact_card.note
    i.item_type = 'once'
    i.status = 'assigned'
    i.input_method = "contacts"
    if i.user && i.message
      i.save!
      i.add_to_bucket(contact_card.bucket)
      return i
    end
    return nil
  end

  def self.create_from_setup_question params
    i = Item.new
    i.message = params[:setup_question][:response]
    i.user = User.find(params[:auth][:uid])
    i.item_type = 'once'
    i.input_method = 'setup'
    i.status = "outstanding"
    b = Bucket.for_user_and_creation_reason(i.user, params[:setup_question][:question][:parent_id]).first
    i.save!
    if b && b.belongs_to_user?(i.user)
      i.add_to_bucket(b) 
    end
    return i
  end





  # -- DESTROY

  def delete
    self.update_attribute(:status, 'deleted')
  end






  # -- CLOUDINARY

  def upload_main_asset(file)
    public_id = "item_#{Time.now.to_f}_#{self.user_id}"
    url = ""
    # if file.content_type == "image/jpeg"
      url = self.upload_image_to_cloudinary(file, public_id, "jpg") 
      p "*"*50
      p file
      p "*"*50      
    # else
      # url = self.upload_video_to_cloudinary(file, public_id)
    # end
    if url && url.length > 0
      return self.add_media_url(url)
    end
  end

  def upload_image_to_cloudinary(file, public_id, format)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format, :angle => :exif)
    return data['url']
  end

  def upload_video_to_cloudinary(file, public_id)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :resource_type => 'raw')
    return data['url']
  end

  def add_media_url url
    if !self.media_urls
      self.media_urls = []
    end
    self.media_urls << url
    return self.media_urls
  end

  def upload_media arr
    if arr && arr.count > 0
      arr.each do |url|
        self.upload_main_asset(url)
      end
    end
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
      self.update_status('assigned')
    else
      self.update_status('outstanding')
    end
  end

  def update_deleted
    if self.has_buckets?
      self.update_status('assigned')
    else
      self.update_status('deleted')
    end
  end

  def add_to_bucket b
    BucketItemPair.with_or_create_with_bucket_id_and_item_id(b.id, self.id)
  end

  def update_status(new_status)
    self.update_attribute(:status, new_status)
  end

  def update_message(new_message)
    self.update_attributes(:message => new_message)
    return self
  end
  
  def update_buckets_string
    self.update_attributes(:buckets_string => self.description_string)
  end




  
  # -- HELPERS

  def has_media?
    return (self.media_urls && self.media_urls.count > 0)
  end

  def description_string
    s = ''
    self.buckets.each do |b|
      s = "#{s} #{b.display_name}"
    end
    s = nil if s == ''
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
    return ['once', 'yearly', 'monthly', 'weekly', 'daily']
  end

  def once?
    self.item_type == "once"
  end

  def daily?
    self.item_type == "daily"
  end

  def weekly?
    self.item_type == "weekly"
  end
  
  def monthly?
    self.item_type == "monthly"
  end

  def yearly?
    self.item_type == "yearly"
  end

  def is_most_recent_request?(timestamp)
    return !self.device_request_timestamp || timestamp.to_f > self.device_request_timestamp
  end

  def user_ids_array
    arr = [self.user_id]
    self.buckets.includes(:users).each do |b|
      b.users.each do |u|
        arr << u.id
      end
    end
    return arr.uniq
  end

  def users_array
    arr = [self.user]
    self.buckets.includes(:users).each do |b|
      b.users.each do |u|
        arr << u
      end
    end
    return arr.uniq
  end
  
  def visible_buckets_for_user(u)
    bucket_ids = self.buckets.pluck(:id)
    bups = BucketUserPair.for_bucket_ids_and_phone(bucket_ids, u.phone)
    return bups.inject([]) { |arr, bup| arr << bup.bucket } #returns array of buckets
  end

  def json_representation(u)
    return self.as_json.merge(:buckets => self.visible_buckets_for_user(u), :user => self.user.as_json(only: [:phone, :name]))
  end





  # -- LINK HANDLING

  def extract_links
    self.assign_attributes(links: (self.message ? URI.extract(self.message, ['http', 'https']) : []))
  end






  # -- AUTO-DATE DETECTION

  def check_for_and_set_date
    return if !self.message || self.message.length == 0 || self.message.length > 110
    begin  
      n = Nickel.parse self.message, DateTime.now.in_time_zone('Central Time (US & Canada)')
      if n.occurrences.count > 0 && n.occurrences.first.type.to_s != 'daily' # ----THIS WOULD BE IF YOU WANT TO EXCLUDE DATES LIKE TODAY----   && time > (Time.now+1.day).beginning_of_day
        self.assign_attributes(reminder_date: n.occurrences.first.start_date.to_date, item_type: self.reminder_frequency_with_nickel_keyword(n.occurrences.first.type.to_s))
      end      
    rescue
    end 
  end

  def reminder_frequency_with_nickel_keyword k
    return "yearly" if self.guess_yearly_reminder?
    return "once" if k == 'single'
    return "monthly" if k == 'daymonthly'
    return "monthly" if k == 'datemonthly'
    return "daily" if k == 'daily'
    return "weekly" if k == 'weekly'
    return "once"
  end

  def guess_yearly_reminder?
    return false if !self.message
    lowercase_str = self.message.downcase
    ['bday', 'birthday', 'married', 'anniversary', 'annvsray', 'born', 'died', 'funeral', 'wedding', 'passed away', 'marry'].each do |check_for|
      return true if lowercase_str.include?(check_for)
    end
    return false
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
    items = Item.notes_for_today.not_deleted
    items.each do |i|
      users = i.users_array
      message = "Reminder (once):\n" + i.message
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, message, "remind_once", i.media_urls)
      end
    end
  end

  def self.remind_about_daily_items
    items = Item.daily.not_deleted
    items.each do |i|
      users = i.users_array
      message = "Reminder (daily):\n" + i.message
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, message, "remind_daily", i.media_urls)
      end
    end
  end

  def self.remind_about_weekly_items
    items = Item.get_weekly_items_for_today
    items.each do |i|
      users = i.users_array
      message = "Reminder (weekly):\n" + i.message
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, message, "remind_weekly", i.media_urls)
      end
    end
  end

  def self.get_weekly_items_for_today
    epoch = Date.parse("1/1/1970")
    days_mod = (Time.zone.now.to_date - epoch).to_i%7
    items = []

    Item.weekly.not_deleted.each do |i|
      if (i.reminder_date - epoch).to_i%7 == days_mod
        items << i
      end
    end
    return items
  end

  def self.remind_about_monthly_items
    items = Item.where('extract(day from reminder_date) = ?', Time.zone.now.to_date.day).monthly.not_deleted

    items.each do |i|
      users = i.users_array
      message = "Reminder (monthly):\n" + i.message
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, message, "remind_monthly", i.media_urls)
      end
    end
  end

  def self.remind_about_yearly_items
    items = Item.where('extract(month from reminder_date) = ? AND extract(day from reminder_date) = ?', Time.zone.now.to_date.month, Time.zone.now.to_date.day).yearly.not_deleted
    
    items.each do |i|
      users = i.users_array
      message = "Reminder (yearly):\n" + i.message
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, message, "remind_yearly", i.media_urls)
      end
    end
  end


  def next_reminder_date
    if self.reminder_date.nil? || (self.reminder_date < Time.zone.now.to_date && self.once?)
      return nil
    else
      d = self.reminder_date 
      case self.item_type
      when "once"
        #d is already set to reminder_date
      when "daily"
        d =  Time.zone.now.to_date
      when "weekly"
        while d < Time.zone.now.to_date
          d = d + 7.days
        end
      when "monthly"
        while d < Time.zone.now.to_date
          d = d + 1.month
        end
      when "yearly"
        while d < Time.zone.now.to_date
          d = d + 1.year
        end
      end
      return d
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
      begin
        client.create_or_update_document(engine_slug, document_slug, self.index_representation)
      rescue Exception => e
        puts 'rescued a swiftype exception!'
      end
    end
  end

  def index_representation
    return {:external_id => self.id, :fields => [
      {:name => 'message', :value => self.message, :type => 'string'},
      {:name => 'text', :value => self.message, :type => 'text'},
      {:name => 'user_id', :value => self.user_id, :type => 'integer'},
      {:name => 'available_to', :value => self.user_ids_array, :type => 'integer'},
      {:name => 'item_type', :value => self.item_type, :type => 'string'},
      {:name => 'buckets_string', :value => self.description_string, :type => 'string'},
      {:name => 'media_urls', :value => self.media_urls, :type => 'string'},
      {:name => 'item_id', :value => self.id, :type => 'integer'},
      {:name => 'latitude', :value => self.latitude, :type => 'float'},
      {:name => 'longitude', :value => self.longitude, :type => 'float'},
      {:name => 'reminder_date', :value => self.reminder_date, :type => 'string'},
      {:name => 'created_at_server', :value => self.created_at, :type => 'string'},
      {:name => 'updated_at_server', :value => self.updated_at, :type => 'string'},
    ]}
  end

  def remove_from_engine
    client = Swiftype::Client.new
    # The automatically created engine has a slug of 'engine'
    engine_slug = 'engine'
    document_slug = 'items'
    begin
      client.destroy_document(engine_slug, document_slug, self.id)
    rescue Exception => e
      puts 'rescued a swiftype exception!'
    end
  end


  def self.index_bulk_wrapper
    cur = []
    Item.all.each_with_index do |item, i|
      cur << item.index_representation
      if i%100 == 0
        Item.index_bulk(cur)
        cur = []
      end
    end
    Item.index_bulk(cur)
  end

  def self.index_bulk items
    client = Swiftype::Client.new
    # The automatically created engine has a slug of 'engine'
    engine_slug = 'engine'
    document_slug = 'items'
    # create Documents within the DocumentType
    begin
      client.create_or_update_documents(engine_slug, document_slug, items)
    rescue Exception => e
      puts 'rescued a swiftype exception!'
    end
  end

end

