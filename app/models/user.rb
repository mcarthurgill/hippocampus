class User < ActiveRecord::Base
  attr_accessible :phone, :country_code

  has_many :people
  has_many :items

  def self.remind_about_outstanding_items
    items = Item.outstanding.uniq_by {|i| i.user_id }
    items.each do |i|
      msg = TwilioMessenger.new(i.user.phone, Hippocampus::Application.config.phone_number, "You wanted to remember something recently and used Hippocampus to help. Open the app and we'll remind you!")
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
end
