class User < ActiveRecord::Base
  attr_accessible :email, :phone, :country_code
  extend Formatting

  # -- RELATIONSHIPS

  has_many :buckets
  has_many :items
  has_many :tokens

  # -- CALLBACKS
  after_create :should_create_default_buckets_and_items

  def should_create_default_buckets_and_items
    self.delay.create_default_buckets_and_items if self.buckets.empty?
  end

  def create_default_buckets_and_items
    b = Bucket.create(:first_name => "McArthur Gill", :user_id => self.id, :bucket_type => "Person")

    hometown = Item.create(:user_id => self.id, :message => "From Montgomery, AL", :item_type => "once", :status => "outstanding")
    hometown.add_to_bucket(b)

    school = Item.create(:user_id => self.id, :message => "Went to Vanderbilt", :item_type => "once", :status => "outstanding")
    school.add_to_bucket(b)

    birthday = Item.create(:user_id => self.id, :message => "September 10th", :item_type => "yearly", :status => "outstanding", :reminder_date => Date.parse("10-9-2015"))
    birthday.add_to_bucket(b)

    current_town = Item.create(:user_id => self.id, :message => "Currently lives in Nashville. Sam and Will are his roommates", :item_type => "once", :status => "pending")

    wine = Bucket.create(:first_name => "Wine", :user_id => self.id, :bucket_type => "Other") 

    meiomi = Item.create(:user_id => self.id, :message => "Really great red wine. Not too heavy.", :item_type => "once", :status => "outstanding")
    meiomi.add_to_bucket(wine)

    cuvaison = Item.create(:user_id => self.id, :message => "Delicious. Drinkable, but has plenty of flavor", :item_type => "once", :status => "outstanding")
    cuvaison.add_to_bucket(wine)
  end
  
  # -- GETTERS

  def self.with_phone_number phone_number
    return User.with_phone_number_and_country_code(phone_number, '1')
  end

  def self.with_phone_number_and_country_code phone_number, country_code
    return User.find_by_phone(self.format_phone(phone_number, country_code))
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
    return User.with_or_initialize_with_phone_number_and_country_code(phone_number, '1')
  end

  def self.with_or_initialize_with_phone_number_and_country_code phone_number, country_code
    user = User.with_phone_number_and_country_code(phone_number, country_code)
    if !user
      user = User.new
      user.phone = User.format_phone(phone_number, country_code)
      user.country_code = User.prepare_country_code!(country_code)
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

  def phone_without_country_code
    return self.phone && self.phone.length > 0 ? self.phone[1..-1] : ''
  end

  def sorted_reminders(limit=64, page=0)
    self.items.not_deleted.with_reminder.limit(limit).offset(limit*page).delete_if{ |i| i.once? && i.reminder_date < Date.today }.sort_by(&:next_reminder_date)
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
  
  def self.validated_with_id_addon_and_token(user_id, addon, token_string)
    u = User.find(user_id)
    if u && addon
      t = Token.for_user_and_addon(u.id, addon.id).live.first
      if t && t.token_string == token_string
        return u
      end
    end
    return nil
  end


# --- ADDONS

  def add_to_addon(addon)
    t = Token.find_or_initialize_by_user_id_and_addon_id(self.id, addon.id)
    if t.new_record?
      t.assign_token 
      t.save
      b = Bucket.create_for_addon_and_user(addon, self)
      Addon.delay.create_user_for_addon(self, addon, b)
    end

    t.update_status("live") if !t.live?
    return t
  end

  def remove_from_addon(addon)
    t = Token.for_user_and_addon(self.id, addon.id).live
    t.update_status("deleted")
  end

  def items_for_addon(params)
    b = Bucket.find(params["user"]["bucket_id"])
    return b ? b.items.not_deleted.by_date : nil
  end

  def self.login_from_addon(params, addon)
    u = User.find_by_phone(params["phone_number"])
    if u 
      return_hash = {:user => {}}
      return_hash[:user][:hippocampus_user_id] = u.id
      return return_hash
    end
    return nil
  end
end
