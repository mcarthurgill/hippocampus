class User < ActiveRecord::Base

  attr_accessible :email, :calling_code, :country_code, :local_key, :medium_id, :membership, :number_items, :number_buckets, :number_buckets_allowed, :name, :object_type, :phone, :salt, :setup_completion, :time_zone, :last_activity
  
  extend Formatting
  include Formatting
  



  # -- RELATIONSHIPS

  has_many :groups
  has_many :group_buckets, :through => :groups, :class_name => "Bucket", :source => :buckets

  has_many :bucket_user_pairs, :foreign_key => "phone_number", :primary_key => :phone
  has_many :buckets, :through => :bucket_user_pairs, :foreign_key => "phone_number", :primary_key => :phone
  
  has_many :items

  has_many :bucket_items, :through => :buckets, :class_name => "Item", :source => :items

  has_many :tokens
  has_many :device_tokens

  has_many :media

  belongs_to :medium

  has_many :tags



  # -- VALIDATORS

  validates_presence_of :phone
  validates_uniqueness_of :phone, case_sensitive: false
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true, :allow_nil => true

  def validate_with_token token
    return true if token == self.current_token
    return true if token == self.token_with_shift(-1)
    return token == self.token_with_shift(1)
  end

  def current_token
    return self.token_with_shift(0)
  end

  def token_with_shift shift
    return String.auth_token(self.salt, self.id%116+shift)
  end
  
  


  # -- CALLBACKS

  after_create :should_send_introduction_text
  def should_send_introduction_text
    self.send_introduction_text
  end

  def send_introduction_text
    message = "Hey there! People use Hippo to invest in their networks.\n\nAlso, store this number in your phone and text it any time you want to remember a thought. Try it out now!"
    OutgoingMessage.send_text_to_number_with_message_and_reason(self.phone, message, "day_1")
  end

  after_initialize :default_values
  def default_values
    self.time_zone ||= 'America/Chicago'
    self.salt ||= String.random(16)
    self.number_buckets_allowed ||= 3
  end

  before_save :downcase_email
  def downcase_email
    self.email = self.email.downcase.strip if self.email
  end

  before_save :update_last_activity
  def update_last_activity
    self.assign_attributes(:last_activity => DateTime.now)
  end

  def should_update_last_activity
    self.update_last_activity
    self.save
  end


  after_save :set_defaults
  def set_defaults
    self.local_key ||= "user--#{self.id}"
  end




  # -- GETTERS

  def self.with_phone_number phone_number
    return User.find_or_create_by_phone(format_phone(phone_number))
  end

  def self.with_phone_number_and_calling_code phone_number, calling_code
    return User.find_by_phone(format_phone(phone_number, calling_code))
  end

  def self.with_phone phone_number
    return User.find_by_phone(format_phone(phone_number))
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
  
  def push_channel
    return "user-#{self.id}"
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
    if !params.has_key?(:updated_at) || params[:updated_at].to_s.length == 0 || params[:updated_at] >= self.updated_at
      if params[:name] && params[:name].length > 0
        self.update_name(params[:name], true)
        self.assign_attributes(name: params[:name])
      end
      if params[:membership] && params[:membership].length > 0
        self.assign_attributes(membership: params[:membership])
      end
      if params[:setup_completion] && params[:setup_completion].length > 0
        self.update_setup_completion(params[:setup_completion])
      end
      if params[:percentage] && params[:percentage].length > 0
        self.update_setup_completion(params[:percentage])
      end
      if params[:time_zone] && params[:time_zone].length > 0
        self.assign_attributes(time_zone: params[:time_zone])
      end
      if params[:email] && params[:email].length > 0
        self.assign_attributes(email: params[:email].downcase.strip)
      end
      if params.has_key?(:file) && params[:file]
        m = Medium.create_with_file_and_user_id(params[:file], self.id)
        self.assign_attributes(medium_id: m.id)
      end
      self.save
    end
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
      self.save
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
      i.message = 'Welcome to Hippo, your personal relationship manager. This is an example note. Get started by adding a note about someone below.'
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

  def sorted_reminders(limit=100000, page=0, return_local_keys=true)
    tz = self.time_zone ? self.time_zone : "America/Chicago"
    items = self.items.not_deleted.with_future_reminder(tz)
    ids_to_exclude = items.pluck(:id)
    items += self.bucket_items.not_deleted.with_future_reminder(tz).excluding(ids_to_exclude)
    sorted_by_date = []
    if return_local_keys
      items_hash = items.group_by{|i| i.next_reminder_date(tz) }
      items_hash.each do |k, v| 
        items_hash[k] = v.map(&:local_key)
        sorted_by_date << Hash[k, items_hash[k]]
      end
      return sorted_by_date.sort_by{|h| h.keys.first}.unshift({:nudges_list => items.map(&:local_key)}) #returns [{date => [item_local_keys]}, {date => [item_local_keys]}] sorted by date
    else
      return items.sort_by{|i| i.next_reminder_date}[(page*limit)...limit+(page*limit)] #returns [item, item, item] sorted by next reminder date
    end
  end

  def no_name?
    return self.name.nil? || self.name == "You"
  end

  def first_name
    if self.name && self.name.length > 0
      return self.name.split(' ').first
    end
    return nil
  end

  def hippo_admin?
    self.phone == "+1111111111"
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

  def avatar_path
    return self.medium.media_url if self.medium_id && self.medium && self.medium.media_url
    default_url = "https://res.cloudinary.com/hbztmvh3r/image/upload/l_text:arial_55:#{self.representative_letter},co_white/v1440726309/avatar_#{self.id%3}.jpg"
    gravatar_id = self.email ? Digest::MD5.hexdigest(self.email.downcase) : "feoaihfoiwejafouwehfaoi@peoihafoweihga.com"
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=96&d=#{CGI.escape(default_url)}"
  end

  def representative_letter
    return self.name[0].upcase if self.name && self.name.length > 0
    return self.email[0].upcase if self.email && self.email.length > 0
    return "?"
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
    return self.items.outstanding.count #+ self.bucket_user_pairs.has_unseen_items.count
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

