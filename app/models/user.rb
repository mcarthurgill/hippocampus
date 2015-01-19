class User < ActiveRecord::Base
  attr_accessible :email, :phone, :country_code
  extend Formatting

  # -- RELATIONSHIPS

  has_many :buckets
  has_many :items
  has_many :tokens
  
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
    items = Item.outstanding.uniq_by {|i| i.user_id }
    items.each do |i|
      if i.user.phone != "12059360524"
        msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, "You have pending notes on Hippocampus. Open the app to handle them.")
        msg.send
      end
    end
  end

  def self.remind_about_events
    items = Item.notes_for_today
    items.each do |i|
      message = "Your Hippocampus reminder for today:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
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


  # --- TOKEN/ADDON

  def update_and_send_passcode
    t = Token.with_params(user_id: self.id)
    t.assign_token
    t.save
    t.text_login_token(t.token_string)
  end

  def correct_passcode? code
    Token.match(code, self.id, nil).recent.live.count > 0
  end
  
  def self.validated_with_id_addon_and_token_and_bucket_id(user_id, addon, token_string, bucket_id)
    u = User.find(user_id)
    a = Addon.find_by_addon_name(addon)
    if u && a
      t = Token.for_user_and_addon(u.id, a.id).live.first
      b = Bucket.find(bucket_id)
      if t && t.token_string == token_string && b && b.belongs_to_user?(u)
        return u
      end
    end
    return nil
  end

  def add_to_addon(addon)
    t = Token.find_or_initialize_by_user_id_and_addon_id(self.id, addon.id)
    if t.new_record?
      t.assign_token 
      t.save
      b = Bucket.create_for_addon_and_user(addon, self)
      Addon.create_user_for_addon(self, addon, b)
    end

    t.update_status("live") if !t.live?
    return t
  end

  def remove_from_addon(addon)
    t = Token.for_user_and_addon(self.id, addon.id).live
    t.update_status("deleted")
  end
end
