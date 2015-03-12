desc "This texts all users who have outstanding items"
task :send_reminders_about_outstanding_items => :environment do
  p "*"*50
  p "texting users about their outstanding items"
  User.remind_about_outstanding_items
  p "done"
  p "*"*50
end

desc "This texts all users about their events today"
task :send_reminders_about_events => :environment do
  p "*"*50
  p "texting users about their events"
  Item.remind_about_events
  p "done"
  p "*"*50
end

#havent added this to the heroku scheduler yet
desc "Let people know they can text hippocampus"
task :alert_about_ability_to_text => :environment do
  p "*"*50
  p "letting people know they can text hippo"
  users = User.where("created_at > ?", 1.day.ago)

  if users && users.count > 0
    users.each do |u|
      message = "Add this number to your contacts. You can text notes to this number and they'll be in Hippocampus waiting for you."
      msg = TwilioMessenger.new(u.phone, Hippocampus::Application.config.phone_number, message)
      msg.send
    end
  end

  p "done"
  p "*"*50
end

desc "Text three random notes a day to those interested"
task :send_random_notes => :environment do 
  p "*"*50
  p "texting random notes"
  # users = User.where("phone = ? OR phone = ?", "12059360524", "13343994374")
  users = User.where("phone = ?", "13343994374")
  users.each do |u|
    # items = u.items.assigned.limit(3).order("RANDOM()")
    items = [Item.find(22)]
    items.each do |i|
      txt_message = "#{i.buckets.first.first_name} - #{i.message}"
      text = TwilioMessenger.new(u.phone, Hippocampus::Application.config.phone_number, txt_message)
      text.send
    end
  end
  p "done"
  p "*"*50
end

require "net/http"
 
desc "Ping app"
task :ping => :environment do
  #it throws a 500 error, but should still wake up the server
  url = 'hippocampus-app.herokuapp.com'
 
  puts "ping? (#{url})"
  r = Net::HTTP.new(url, 80).request_head('/')
  puts "pong! (#{r.code} #{r.message})"
end