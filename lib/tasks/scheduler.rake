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

desc "This text goes to mcarthur and sends him one random bucket a day"
task :send_mcarthur_text => :environment do 
  p "*"*50
  p "texting mcarthur to say whatup"
  u = User.find(1)
  bucket = u.buckets.sample
  txt_message = "You Bucket for Today: #{bucket.first_name} #{bucket.last_name}"
  text = TwilioMessenger.new(u.phone, Hippocampus::Application.config.phone_number, txt_message)
  text.send
  bucket.items.each do |i|
    text = TwilioMessenger.new(u.phone, Hippocampus::Application.config.phone_number, i.message)
    text.send
  end
  p "done"
  p "*"*50
end

desc "Text three random notes a day to those interested"
task :send_random_notes => :environment do 
  p "*"*50
  p "texting random notes"
  3.times do 
    u = User.find(1)
    bucket = u.buckets.sample
    item = bucket.items.sample
    txt_message = "#{bucket.first_name} - #{item.message}"
    text = TwilioMessenger.new(u.phone, Hippocampus::Application.config.phone_number, txt_message)
    text.send
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