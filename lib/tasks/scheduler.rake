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
  User.remind_about_events
  p "done"
  p "*"*50
end

desc "This text goes to mcarthur and sends him one random item a day"
task :send_mcarthur_text => :environment do 
  p "*"*50
  p "texting users about their events"
  u = User.find(1)
  message = u.items.sample.message
  text = TwilioMessenger.new(u.phone, Hippocampus::Application.config.phone_number, message)
  text.send
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