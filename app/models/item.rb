class Item < ActiveRecord::Base

  attr_accessible :audio_url, :buckets_array, :buckets_string, :device_request_timestamp, :device_timestamp, :local_key, :latitude, :longitude, :links, :media_urls, :media_content_types, :message, :message_html_cache, :message_full_cache, :bucket_id, :user_id, :item_type, :reminder_date, :status, :input_method, :object_type, :media_cache

  serialize :media_cache, JSON
  serialize :media_content_types, Array
  serialize :media_urls, Array
  serialize :links, Array
  serialize :buckets_array, Array

  # types: once, yearly, monthly, weekly, daily





  # -- RELATIONSHIPS

  belongs_to :user
  has_many :bucket_item_pairs, dependent: :destroy
  has_many :buckets, :through => :bucket_item_pairs
  # belongs_to :bucket

  has_many :sms
  has_many :emails
  has_many :calls
  has_many :media, class_name: 'Medium', foreign_key: 'item_local_key', primary_key: 'local_key'




  # -- SCOPES

  scope :outstanding, -> { where("status = ?", "outstanding").includes(:user) } 
  scope :assigned, -> { where("status = ?", "assigned").includes(:user) } 
  scope :not_deleted, -> { where("status != ?", "deleted") }
  scope :notes_for_today, -> { where("reminder_date = ? AND item_type = ?", (Time.zone.now - 6.hours).to_date, "once").includes(:user) } 
  scope :daily, -> { where("item_type = ?", "daily").includes(:user) } 
  scope :weekly, -> { where("item_type = ?", "weekly").includes(:user) } 
  scope :monthly, -> { where("item_type = ?", "monthly").includes(:user) } 
  scope :yearly, -> { where("item_type = ?", "yearly").includes(:user) } 
  scope :above, ->(time) { where('"items"."updated_at" > ?', Time.at(time.to_i).to_datetime) }
  scope :before_created_at, ->(time) { where('"items"."created_at" < ?', Time.at(time.to_i).to_datetime) }
  scope :by_date, -> { order('"items"."id" DESC') }
  scope :newest_last, -> { order('"items"."id" ASC') }
  scope :with_reminder, -> { where("reminder_date IS NOT NULL") }
  scope :last_24_hours, -> { where('"items"."created_at" > ? AND "items"."created_at" < ?', 24.hours.ago, Time.now) }
  scope :since_time_ago, ->(time_ago) { where('"items"."created_at" > ?', time_ago) }
  scope :with_long_lat_and_radius, ->(long, lat, rad) { where("((longitude - ?)^2 + (latitude - ?)^2) <= ?", long, lat, rad) }
  scope :within_bounds, ->(max_long, min_long, max_lat, min_lat) { where("longitude <= ? AND longitude >= ? AND latitude <= ? AND latitude >= ?", max_long, min_long, max_lat, min_lat) }
  




  # -- CALLBACKS

  validates :local_key, :uniqueness => true

  before_validation :strip_whitespace
  def strip_whitespace
    self.message = self.message ? self.message.strip : nil
    self.message = self.message[2..-1] if self.message && self.message.length > 2 && self.message[0...2] == "￼\r"
    self.item_type = self.item_type ? self.item_type.strip : nil
    self.status = self.status ? self.status.strip : nil
    self.input_method = self.input_method ? self.input_method.strip : nil
  end

  before_save :check_status
  def check_status
    self.status = "outstanding" if ( !self.deleted? && !self.has_buckets? )
    self.buckets_string = self.description_string
    self.assign_bucket_information
  end

  before_save :set_defaults
  def set_defaults
    self.device_timestamp ||= Time.now.to_f
    self.local_key ||= "item-#{self.device_timestamp}-#{self.user_id}" if self.device_timestamp && self.user_id
  end

  after_create :update_user_items_count
  def update_user_items_count
    self.user.delay.update_items_count
  end

  before_create :check_for_and_set_date

  before_save :extract_links

  after_save :index_delayed

  after_save :alter_buckets_delayed
  before_destroy :alter_buckets

  before_destroy :remove_from_engine

  after_save :push
  def push
    begin
      Pusher.trigger(self.users_array_for_push, 'item-save', self.as_json()) if self.users_array_for_push.count > 0
    rescue Pusher::Error => e
    end
  end

  def users_array_for_push
    arr = []
    self.users_array.each do |u|
      arr << "user-#{u.id}"
    end
    return arr
  end




  # -- SETTERS

  def self.create_with_sms(sms)
    i = Item.new
    i.message = sms.Body
    i.user = User.with_phone_number(sms.From)

    i.media_content_types = sms.MediaContentTypes
    if i.media_is_video?(0)
      OutgoingMessage.send_text_to_number_with_message_and_reason(i.user.phone, "Sorry you must upload videos through the app! Here is a link: https://appsto.re/us/_BWZ5.i", "texted_video_error")
      return
    end

    i.item_type = 'once'
    i.status = 'outstanding'
    i.input_method = 'sms'
    i.save!

    sms.MediaUrls.each_with_index do |url, index|
      Medium.create_with_file_user_id_and_item_id(url, i.user_id, i.id)
    end

    return i
  end

  # NEEDS TO BE UPDATED TO NEW MEDIA TYPE
  def self.create_with_call(call)
    i = Item.new
    i.message = call.TranscriptionText if call.has_transcription?
    i.user = User.with_phone_number(call.From)
    i.audio_url = call.RecordingUrl if call.has_recording?
    i.item_type = 'once'
    i.status = 'outstanding'
    i.input_method = 'call'
    i.save!
    call.assign_attributes(item_id: i.id)

    if call.has_recording?
      m = Medium.create_with_call_user_id_and_item_id(call, i.user_id, i.id)
      call.assign_attributes(medium_id: m.id) if m
    end

    call.save!

    return i
  end

  # NEEDS TO BE UPDATED TO NEW MEDIA TYPE
  def self.create_with_email(email)
    i = Item.new
    i.message = email.parsed_text
    i.message_html_cache = email.HtmlBody
    i.message_full_cache = email.TextBody
    i.user = email.user
    i.item_type = 'once'
    i.status = 'outstanding'
    i.input_method = 'email'
    email.Attachments.each do |a|
      public_id = "item_#{Time.now.to_f}_#{i.user_id}"
      if ["image/jpeg", "image/png", "image/jpg"].include?(a.type)
        file = Tempfile.new(['test', '.jpg']) 
        file.binmode
        file.write a.decoded_content
        file.rewind
        url = i.upload_image_to_cloudinary(file, public_id, "jpg")
        i.add_media_url(url) if url
        file.close
      elsif ["video/3gpp", "video/mov", "video/quicktime"].include?(a.type)
        file = Tempfile.new('video_temp')
        file.binmode
        file.write a.decoded_content
        file.rewind
        url = self.upload_video_to_cloudinary(file, public_id)
        screenshot_url = self.video_thumbnail_url(url)
        self.add_media_url(url) if url
        self.add_media_url(screenshot_url) if url && screenshot_url
        file.close
      end
    end
    i.save!
    return i
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

  def upload_main_asset(file, num_uploaded=0)
    public_id = "item_#{Time.now.to_f}_#{self.user_id}"
    url = ""
    
    if !file.is_a?(String) && file.content_type
      self.media_content_types << file.content_type
    end

    if self.media_is_image?(num_uploaded)
      url = self.upload_image_to_cloudinary(file, public_id, "jpg") 
    elsif self.media_is_video?(num_uploaded)
      url = self.upload_video_to_cloudinary(file, public_id)
      screenshot_url = self.video_thumbnail_url(url)
    end
    if url && url.length > 0
      self.add_media_url(url)
      self.add_media_url(screenshot_url) if screenshot_url
      return self.media_urls
    end
  end

  def media_is_image? index
    image_content_types = ["image/jpeg", "image/png", "image/jpg"]
    return self.media_content_types[index] && image_content_types.include?(self.media_content_types[index])
  end

  def media_is_video? index
    video_content_types = ["video/3gpp", "video/mov", "video/quicktime"]
    return self.media_content_types[index] && video_content_types.include?(self.media_content_types[index])
  end

  def upload_image_to_cloudinary(file, public_id, format)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format, :angle => :exif)
    return data['url']
  end

  def upload_video_to_cloudinary(file, public_id)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :resource_type => :video)
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
      arr.each_with_index do |url, index|
        self.upload_main_asset(url, index)
      end
    end
  end


  def video_thumbnail_url url
    string_to_locate = "/upload/"
    beginning_index = url.index(string_to_locate)
    extension_index = url.index("." + url.split(".").last)
    rest_of_url = url[(beginning_index + string_to_locate.length)...extension_index]

    thumbnail_url = "l_playButton/" + rest_of_url + ".png"
    return thumbnail_url.insert(0, url[0...beginning_index + string_to_locate.length])
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
    self.update_attributes(buckets_string: self.description_string)
  end

  def update_media_cache
    self.assign_media_cache
    self.save!
  end

  def assign_media_cache
    self.media_cache = self.media.as_json
  end

  def update_buckets_with_local_keys_and_user local_keys, u
    all_local_keys = self.bucket_local_keys_without_user_permission(u)
    if local_keys && local_keys.count > 0
      local_keys.each do |lk|
        all_local_keys << lk
      end
    end
    return self.update_buckets_with_local_keys(all_local_keys.uniq)
  end

  def update_buckets_with_local_keys local_keys
    self.alter_buckets
    if local_keys && local_keys.count > 0
      self.buckets = Bucket.find_all_by_local_key(local_keys)
      self.update_outstanding
    else
      self.buckets = []
      self.update_outstanding
    end
    return true
  end

  def bucket_local_keys_without_user_permission u
    temp = []
    self.buckets.each do |b|
      temp << b.local_key if !b.user_has_access?(u)
    end
    puts "TEMP: "
    puts temp
    return temp
  end




  
  # -- HELPERS

  def has_media?
    return (self.media_urls && self.media_urls.count > 0)
  end

  def assign_bucket_information
    self.buckets_array = self.id ? self.buckets.by_first_name.select(['"buckets"."local_key"', '"buckets"."id"', '"buckets"."authorized_user_ids"', '"buckets"."first_name"', '"buckets"."bucket_type"']).as_json : []
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
    return self.as_json.merge(:buckets => self.visible_buckets_for_user(u), :user => self.user.as_json(only: [:phone, :name, :object_type]))
  end

  def _geoloc
    return { lat: self.latitude, lng: self.longitude } if self.latitude && self.longitude
  end

  def date
    return self.created_at.to_f
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
        self.assign_attributes(reminder_date: n.occurrences.first.start_date.to_date)
        self.assign_attributes(item_type: self.reminder_frequency_with_nickel_keyword(n.occurrences.first.type.to_s))
      end      
    rescue
    end 
  end

  def reminder_frequency_with_nickel_keyword k
    return "yearly" if self.guess_yearly_reminder? && k == 'single'
    return "yearly" if self.reminder_date < 1.week.ago.to_date && k == 'single'
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
    ['bday', 'birthday', 'married', 'anniversary', 'annvsray', 'born', 'died', 'funeral', 'wedding', 'passed away', 'marry', 'annual', 'annually', 'every', 'each', 'birthdy', 'brthdy', 'birtday'].each do |check_for|
      return true if lowercase_str.include?(check_for)
    end
    return false
  end






  # -- REMINDERS

  def nudge_buckets_string for_user
    string = ""
    bucks = self.visible_buckets_for_user(for_user)
    return "" if !bucks || bucks.count == 0
    string = " ("
    bucks.each_with_index do |b, i|
      string = string+b.first_name
      string = string+", " if (i+1) < bucks.count
    end
    string = string+")"
    return string
  end

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
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, "Nudge (once)#{i.nudge_buckets_string(u)}:\n" + i.message, "remind_once", i.media_urls)
      end
    end
  end

  def self.remind_about_daily_items
    items = Item.daily.not_deleted
    items.each do |i|
      users = i.users_array
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, "Nudge (daily)#{i.nudge_buckets_string(u)}:\n" + i.message, "remind_daily", i.media_urls)
      end
    end
  end

  def self.remind_about_weekly_items
    items = Item.get_weekly_items_for_today
    items.each do |i|
      users = i.users_array
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, "Nudge (weekly)#{i.nudge_buckets_string(u)}:\n" + i.message, "remind_weekly", i.media_urls)
      end
    end
  end

  def self.get_weekly_items_for_today
    epoch = Date.parse("1/1/1970")
    days_mod = ((Time.zone.now - 6.hours).to_date - epoch).to_i%7
    items = []

    Item.weekly.not_deleted.each do |i|
      if (i.reminder_date - epoch).to_i%7 == days_mod
        items << i
      end
    end
    return items
  end

  def self.remind_about_monthly_items
    items = Item.where('extract(day from reminder_date) = ?', (Time.zone.now - 6.hours).to_date.day).monthly.not_deleted

    items.each do |i|
      users = i.users_array
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, "Nudge (weekly)#{i.nudge_buckets_string(u)}:\n" + i.message, "remind_monthly", i.media_urls)
      end
    end
  end

  def self.remind_about_yearly_items
    items = Item.where('extract(month from reminder_date) = ? AND extract(day from reminder_date) = ?', (Time.zone.now - 6.hours).to_date.month, (Time.zone.now - 6.hours).to_date.day).yearly.not_deleted
    
    items.each do |i|
      users = i.users_array
      users.each do |u|
        OutgoingMessage.send_text_to_number_with_message_and_reason(u.phone, "Nudge (yearly)#{i.nudge_buckets_string(u)}:\n" + i.message, "remind_yearly", i.media_urls)
      end
    end
  end


  def next_reminder_date
    if self.reminder_date.nil? || (self.reminder_date < (Time.zone.now - 6.hours).to_date && self.once?)
      return nil
    else
      d = self.reminder_date 
      case self.item_type
      when "once"
        #d is already set to reminder_date
      when "daily"
        d =  (Time.zone.now - 6.hours).to_date
      when "weekly"
        while d < (Time.zone.now - 6.hours).to_date
          d = d + 7.days
        end
      when "monthly"
        while d < (Time.zone.now - 6.hours).to_date
          d = d + 1.month
        end
      when "yearly"
        while d < (Time.zone.now - 6.hours).to_date
          d = d + 1.year
        end
      end
      return d
    end
  end
  
  def alter_buckets_delayed
    self.delay.alter_buckets
  end

  def alter_buckets
    self.buckets.each do |b|
      b.delay.set_relation_level
    end
  end

  def self.remove_old_reminders
    Item.where('item_type = ? AND reminder_date IS NOT NULL AND reminder_date < ?', 'once', (Time.zone.now - 6.hours).to_date).each do |i|
      i.update_attribute(:reminder_date, nil)
    end
  end


  # algolia

  include AlgoliaSearch

  algoliasearch unless: :deleted? do
    # all attributes + extra_attr will be sent
    add_attribute :user_ids_array, :_geoloc, :date
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

