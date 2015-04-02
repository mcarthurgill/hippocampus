class User < ActiveRecord::Base

  attr_accessible :email, :phone, :calling_code, :country_code, :number_items, :number_buckets
  extend Formatting
  include Formatting
  

  # -- RELATIONSHIPS

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

  # after_create :should_create_default_buckets_and_items, :should_send_introduction_text
  # def should_create_default_buckets_and_items
  #   self.delay.create_default_buckets_and_items if self.buckets.empty?
  # end

  # def create_default_buckets_and_items
  #   quotes = Bucket.create(:first_name => "Quotes (Sample Thread)", :user_id => self.id, :bucket_type => "Other") 
  #   b = Bucket.create(:first_name => "Tom Hanks (Sample Thread)", :user_id => self.id, :bucket_type => "Person")
  #   c = Bucket.create(:first_name => "Emily Scott (Sample Thread)", :user_id => self.id, :bucket_type => "Person")
  #   q7 = Item.create(:user_id => self.id, :message => "\"You are no more than a few seconds of attention other people give to a Facebook status. In 2014, no one has time to care about others in such a crowded, noisy world.\". (Sample Note)", :item_type => "once", :status => "assigned")
  #   q7.add_to_bucket(quotes)
  #   q1 = Item.create(:user_id => self.id, :message => '"We are interested in others when they are interested in us." -Dale Carnegie (Sample Note)', :item_type => "once", :status => "assigned")
  #   q1.add_to_bucket(quotes)
  #   q2 = Item.create(:user_id => self.id, :message => '"Some of Virgin\'s most successful companies have been born from random moments. If we hadn\'t opened our notebooks, they would never have happened." -Richard Branson (Sample Note)', :item_type => "once", :status => "assigned")
  #   q2.add_to_bucket(quotes)
  #   school = Item.create(:user_id => self.id, :message => "Went to Cal State before moving to Hollywood. (Sample Note)", :item_type => "once", :status => "assigned")
  #   school.add_to_bucket(b)
  #   birthday = Item.create(:user_id => self.id, :message => "Birthday - July 9th (Sample Note)", :item_type => "yearly", :status => "assigned", :reminder_date => Date.parse("2015-07-09"))
  #   birthday.add_to_bucket(b)
  #   c1 = Item.create(:user_id => self.id, :message => "Leaving today for India. She's going to visit her college roommate in Mumbai. (Sample Note)", :item_type => "once", :status => "assigned", :reminder_date => Time.now+10.days)
  #   c1.add_to_bucket(c)
  #   c2 = Item.create(:user_id => self.id, :message => "Roommate names are Kate (brunette) and Sarah. (Sample Note)", :item_type => "once", :status => "assigned")
  #   c2.add_to_bucket(c)
  #   c3 = Item.create(:user_id => self.id, :message => "Getting her wisdom teeth removed. (Sample Note)", :item_type => "once", :status => "assigned", :reminder_date => Time.now+3.days)
  #   c3.add_to_bucket(c)
  #   q3 = Item.create(:user_id => self.id, :message => '"A lot of people died fighting tyranny. The least I can do is vote against it." -Carl Icahn at Texaco annual meeting, 1988 (Sample Note)', :item_type => "once", :status => "assigned")
  #   q3.add_to_bucket(quotes)
  #   q5 = Item.create(:user_id => self.id, :message => "\"Evil is relatively rare. Ignorance is an epidemic.\" -Jon Stewart (Sample Note)", :item_type => "once", :status => "assigned")
  #   q5.add_to_bucket(quotes)
  #   c4 = Item.create(:user_id => self.id, :message => "Went to Desano's with Emily. Had a bottle of 'Los Dos', recommended by Ed. Was light-bodied and paired well with pizza. (Sample Note)", :item_type => "once", :status => "assigned", :media_urls => ["http://res.cloudinary.com/hbztmvh3r/image/upload/v1425318520/item_1425318520.1776307_2.jpg"])
  #   c4.add_to_bucket(c)
  #   f1 = Item.create(:user_id => self.id, :message => "Wife is Rita Wilson, has two kids w/ Rita: Chester and Marlon. (Sample Note)", :item_type => "once", :status => "assigned")
  #   f1.add_to_bucket(b)
  # end
  
  def should_send_introduction_text
    self.delay.send_introduction_text
  end

  def send_introduction_text
    message = "Hippocampus.\nYour thoughts, forever.\n\nWelcome! Most people use Hippocampus to remember a friend's birthday or the name of someone they met at a party. Hippocampus is also a great way to remember the name of your coworker's daughter or a profound quote. Text Hippocampus anything you don't want to forget.\n\nTo get you started, here are a few questions. What's your best friend's birthday?\n(reply to this text)"
    msg = TwilioMessenger.new(self.phone, Hippocampus::Application.config.phone_number, message)
    msg.send
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
    all_bucket = Bucket.new(:first_name => "All Notes", :items_count => self.items.outstanding.count, :updated_at => self.items.last ? self.items.last.updated_at : DateTime.now)
    all_bucket.id = 0
    return_buckets = [all_bucket]
    return_buckets << self.buckets.recent_for_user_id(self.id).order('updated_at DESC')
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
    end
    return user
  end


  
  # -- SCHEDULES

  def self.remind_about_outstanding_items
    items = Item.outstanding.last_24_hours.uniq_by {|i| i.user_id }
    items.each do |i|
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, "You have pending notes on Hippocampus. Open the app to handle them.")
      msg.send
    end
  end

  

  # -- HELPERS

  def formatted_buckets_options
    buckets = [["", nil]]
    self.buckets.order("first_name ASC").each do |b|
      buckets << [b.display_name, b.id]
    end
    return buckets
  end

  def sorted_reminders(limit=100000, page=0)
    self.items.not_deleted.with_reminder.limit(limit).offset(limit*page).delete_if{ |i| i.once? && i.reminder_date < Date.today }.sort_by(&:next_reminder_date)
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
