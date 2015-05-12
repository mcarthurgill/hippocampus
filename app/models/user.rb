class User < ActiveRecord::Base

  attr_accessible :email, :phone, :calling_code, :country_code, :number_items, :number_buckets, :name, :setup_completion, :time_zone
  
  extend Formatting
  include Formatting
  



  # -- RELATIONSHIPS

  has_many :groups
  has_many :group_buckets, :through => :groups, :class_name => "Bucket", :source => :buckets

  has_many :bucket_user_pairs, :foreign_key => "phone_number", :primary_key => :phone
  has_many :buckets, :through => :bucket_user_pairs, :foreign_key => "phone_number", :primary_key => :phone
  has_many :items
  has_many :tokens
  has_many :device_tokens




  # -- VALIDATORS

  validates_presence_of :phone
  validates_uniqueness_of :phone, case_sensitive: false
  
  


  # -- CALLBACKS
  after_create :should_send_introduction_text
  def should_send_introduction_text
    self.send_introduction_text
  end

  def send_introduction_text
    message = "Hippocampus.\nTo be interesting, be interested.\n\nWelcome! Most people use Hippocampus to remember a friend's birthday or the name of someone they met at a party. Hippocampus is also a great way to remember the name of your coworker's daughter or a profound quote. Text Hippocampus anything you don't want to forget and start making people feel like they matter.\n\nTo get you started, here are three questions. 1) Who was the last person you met and what did you learn about them?\n(reply to this text)"
    OutgoingMessage.send_text_to_number_with_message_and_reason(self.phone, message, "day_1")
  end

  after_initialize :default_values
  def default_values
    self.time_zone ||= 'America/Chicago'
  end




  # -- GETTERS

  def self.with_phone_number phone_number
    return User.find_or_create_by_phone(format_phone(phone_number))
  end

  def self.with_phone_number_and_calling_code phone_number, calling_code
    return User.find_by_phone(format_phone(phone_number, calling_code))
  end

  def self.with_email e
    return User.find_by_email(e.strip.downcase)
  end

  def recent_buckets_with_shell
    all_bucket = Bucket.new(:first_name => "All Thoughts", :items_count => self.items.outstanding.count, :updated_at => self.items.last ? self.items.last.updated_at : DateTime.now)
    all_bucket.id = 0
    return_buckets = [all_bucket]
    return_buckets << self.buckets.select("buckets.*,bucket_user_pairs.last_viewed,bucket_user_pairs.unseen_items").order('updated_at DESC').limit(4) # self.buckets.recent_for_user_id(self.id).order('updated_at DESC')
    return return_buckets.flatten
  end
  




  # -- SETTERS

  def self.with_or_initialize_with_phone_number phone_number
    return User.with_or_initialize_with_phone_number_country_code_and_calling_code(phone_number, 'US', '1')
  end

  def self.with_or_initialize_with_phone_number_country_code_and_calling_code phone_number, country_code, calling_code
    user = User.with_phone_number_and_calling_code(phone_number, calling_code)
    if !user
      user = User.new
      user.phone = format_phone(phone_number, calling_code)
      user.calling_code = prepare_calling_code!(calling_code)
      user.country_code = country_code
      user.update_name(nil) #update name from bups
    end
    return user
  end

  def update_with_params params
    if params[:name] && params[:name].length > 0
      self.update_name(params[:name], true)
    end
    if params[:setup_completion] && params[:setup_completion].length > 0
      self.update_setup_completion(params[:setup_completion])
    end
    if params[:percentage] && params[:percentage].length > 0
      self.update_setup_completion(params[:percentage])
    end
    self.save
    return true
  end

  def update_name n, override=false
    if n.nil? 
      bup = BucketUserPair.for_phone_number(self.phone).limit(1).first 
      n = bup.name if bup
    end
    if self.set_name(n)
      BucketUserPair.delay.update_all_for_user_name(self) if override
    end
  end

  def set_name n, override=false
    if self.no_name? || override
      self.name = n
      return true
    end
    return false
  end

  def update_setup_completion percentage
    self.setup_completion = percentage
  end

  def set_country_and_calling_codes_from_sm sm
    country_code_text = sm.FromCountry
    country_code_object = CountryCode.find_by_country_code(country_code_text)
    if country_code_object
      self.update_attributes(calling_code: country_code_object.calling_code, country_code: country_code_text)
    end
  end





  # -- HELPERS

  def ungrouped_buckets
    return self.buckets.where('"buckets"."id" NOT IN (?)', self.group_buckets.pluck(:id)).by_first_name if self.group_buckets.pluck(:id).count > 0
    return self.buckets.by_first_name
  end

  def check_for_item
    if self.items.count == 0
      i = Item.new
      # i.message = 'This is an example note. Assign it to a thread! (notes belong to threads)'
      i.message = 'This is an example thought. Assign it to a collection! (thoughts belong to collections)'
      i.user_id = self.id
      i.item_type = 'once'
      i.status = 'outstanding'
      i.input_method = 'system'
      i.save!
    end
  end

  def formatted_buckets_options
    buckets = [["", nil]]
    self.buckets.order("first_name ASC").each do |b|
      buckets << [b.display_name, b.id]
    end
    return buckets
  end

  def sorted_reminders(limit=100000, page=0)
    self.items.not_deleted.with_reminder.limit(limit).offset(limit*page).delete_if{ |i| i.once? && i.reminder_date < (Time.zone.now - 6.hours).to_date }.sort_by(&:next_reminder_date)
  end

  def no_name?
    return self.name.nil? || self.name == "You"
  end

  #with 1519 Ashwood Ave as current location
  #0.000025 - edleys/jenis are not included
  #0.00006 - edleys/jenis in, natchez + charlotte + bridgestone out
  #0.002 - #natchez + charlotte + bridgestone included
  #10.0 - arbitrary large number
  def items_near_location(long, lat)
    long = long.to_f
    lat = lat.to_f
    nearby_items = self.items.not_deleted.limit(64).with_long_lat_and_radius(long, lat, 0.000025)
    nearby_items = self.items.not_deleted.limit(64).with_long_lat_and_radius(long, lat, 0.00006) if nearby_items.empty?
    nearby_items = self.items.not_deleted.limit(64).with_long_lat_and_radius(long, lat, 0.002) if nearby_items.empty?
    nearby_items = self.items.not_deleted.limit(64).with_long_lat_and_radius(long, lat, 10.0) if nearby_items.empty?
    return nearby_items
  end

  def items_within_bounds(centerx, centery, dx, dy)
    centerx = centerx.to_f
    centery = centery.to_f
    dx = dx.to_f
    dy = dy.to_f
    max_long = 0.0
    min_long = 0.0
    max_lat = 0.0
    min_lat = 0.0

    #account for negative values 
    if (centerx + dx) > (centerx - dx)
      max_long = centerx + dx
      min_long = centerx - dx
    else
      max_long = centerx - dx
      min_long = centerx + dx
    end
    if (centery + dy) > (centery - dy)
      max_lat = centery + dy
      min_lat = centery - dy
    else
      max_lat = centery - dy
      min_lat = centery + dy
    end

    return self.items.not_deleted.limit(64).within_bounds(max_long, min_long, max_lat, min_lat)
  end

  def items_since_date_sorted_days date
    hash = Hash.new
    while date < Time.now
      hash[date.strftime('%A, %B %d, %Y')] = self.items.not_deleted.where('created_at > ? AND created_at < ?', date.beginning_of_day, date.end_of_day)
      date = date+1.day
    end
    return hash
  end

  def yesterdays_items_sorted_days
    hash = Hash.new
    date = 1.day.ago
    hash[date.strftime('%A, %B %d, %Y')] = self.items.not_deleted.where('created_at > ? AND created_at < ?', date.beginning_of_day, date.end_of_day)
    return hash
  end

  def score
    return self.number_items+self.number_buckets
  end





  # --- ACTIONS

  def update_items_count
    self.update_attribute(:number_items, self.items.count)
  end

  def update_buckets_count
    self.update_attribute(:number_buckets, self.buckets.count)
  end




  # --- PUSH NOTIFICATIONS

  def unread_badge_count
    return self.items.outstanding.count + self.bucket_user_pairs.has_unseen_items.count
  end

  def send_push_notification_with_message msg
    self.send_push_notification_with_message_and_item_and_bucket(msg, nil, nil)
  end

  def send_push_notification_with_message_and_item_and_bucket msg, i, b
    self.device_tokens.each do |device_token|
      pn = PushNotification.new
      pn.assign_attributes(device_token_id: device_token.id, message: msg, badge_count: self.unread_badge_count, item_id: (i ? i.id : nil), bucket_id: (b ? b.id : nil))
      pn.send_notification
    end
  end



  

  # --- TOKENS

  def update_and_send_passcode
    t = Token.with_params(user_id: self.id)
    t.assign_token
    t.save
    t.text_login_token(t.token_string)
  end

  def correct_passcode? code
    Token.match(code, self.id, nil).recent.live.count > 0
  end
  

end
