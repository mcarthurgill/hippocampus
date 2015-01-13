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
    items = Item.events_for_today
    items.each do |i|
      message = "Your Hippocampus reminder for today:\n" + i.message
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
    end
  end



  # -- HELPERS

  # def format_phone (number, country_code)
  #   return User.format_phone(number, country_code)
  # end

  def formatted_buckets_options
    buckets = [["", nil]]
    self.buckets.order("first_name ASC").each do |b|
      buckets << [b.display_name, b.id]
    end
    return buckets
  end

  # def self.format_phone(number, country_code)
  #   number.gsub!(/\s+/, "")
  #   country_code.gsub!(/\s+/, "")
  #   country_code.gsub!(/\D/, '')
  #   if number && number.first == "+"
  #     return number.gsub!(/\D/, '')
  #   elsif country_code && country_code.length > 0
  #     country_code.gsub!(/\D/, '')
  #     if number.slice(0...country_code.length) == country_code
  #       number.slice!(0...country_code.length)
  #     end
  #     number.sub!(/^0+/, "")
  #     return number.prepend(country_code)
  #   end
  # end

  # def self.prepare_country_code!(country_code)
  #   strip_whitespace!(country_code)
  #   strip_non_numeric!(country_code)
  #   return country_code
  # end



  # --- TOKEN

  def update_and_send_passcode
    t = Token.with_params(user_id: self.id)
    t.assign_token
    t.save
    t.send_token(t.token_string)
  end

  def correct_passcode? code
    Token.match(code, self.id, nil).live.count > 0
  end
end
