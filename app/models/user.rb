class User < ActiveRecord::Base

  attr_accessible :phone, :country_code


  # -- RELATIONSHIPS

  has_many :buckets
  has_many :items


  # -- GETTERS

  def self.with_phone_number phone_number
    return User.find_by_phone(self.format_phone(phone_number, '1'))
  end


  # -- SCHEDULES

  def self.remind_about_outstanding_items
    items = Item.outstanding.uniq_by {|i| i.user_id }
    items.each do |i|
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, "You have pending notes on Hippocampus. Open the app to handle them.")
      msg.send
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

  def format_phone (number, country_code)
    return User.format_phone(number, country_code)
  end

  def self.format_phone(number, country_code)
    number.gsub!(/\s+/, "")
    country_code.gsub!(/\s+/, "")
    country_code.gsub!(/\D/, '')
    if number && number.first == "+"
      return number.gsub!(/\D/, '')
    elsif country_code && country_code.length > 0
      country_code.gsub!(/\D/, '')
      if number.slice(0...country_code.length) == country_code
        number.slice!(0...country_code.length)
      end
      number.sub!(/^0+/, "")
      return number.prepend(country_code)
    end
  end

end
