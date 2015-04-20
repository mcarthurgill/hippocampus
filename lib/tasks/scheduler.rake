desc "This sends a morning summary email"
task :send_summary_emails => :environment do
  p "*"*50
  p "sending users a summary email"
  if Time.now.sunday?
    Email.send_sunday_summaries
  else
    Email.send_daily_summaries
  end
  p "done"
  p "*"*50
end

desc "This texts all users who have outstanding items"
task :send_reminders_about_outstanding_items => :environment do
  p "*"*50
  p "texting users about their outstanding items"
  
  items = Item.outstanding.last_24_hours.includes(:user).uniq_by {|i| i.user_id }
  phones_already_texted = OutgoingMessage.sent_today.pluck(:to_number).uniq
  users_already_texted = User.find_all_by_phone(phones_already_texted)

  items.each do |i|
    if !users_already_texted.include?(i.user)
      message = "You have pending notes on Hippocampus. Open the app to handle them."
      OutgoingMessage.send_text_to_number_with_message_and_reason(i.user.phone, message, "outstanding")
    end
  end

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

require "net/http"
 
desc "Ping app"
task :ping => :environment do
  #it throws a 500 error, but should still wake up the server
  url = 'hippocampus-app.herokuapp.com'
 
  puts "ping? (#{url})"
  r = Net::HTTP.new(url, 80).request_head('/')
  puts "pong! (#{r.code} #{r.message})"
end

desc "7 day tutorial"
task :seven_day_tutorial => :environment do
  p "*"*50
  p "texting users going through the tutorial"

  messages = [
    "Day 7 of 7: Do you know anyone going on a trip? If so, when are they leaving?", 
    "Day 6 of 7: What is the best gift you've received lately? Who else would like that gift?", 
    "Day 5 of 7: What is your favorite coworker's Chipotle order?", 
    "Day 4 of 7: What is your barber's name?", 
    "Day 3 of 7: What is your favorite barista's name at your favorite coffee shop?", 
    "Yesterday you completed the first day of our seven day Hippocampus tutorial. Each day we will ask you a question to help you build the habits to make people feel like they matter.\n\nSo, what's the name of your favorite coworker's spouse? Do they have kids? How did they meet?"
  ]
  reasons = ["day_7", "day_6", "day_5", "day_4", "day_3", "day_2", "day_1"]
  exclude_phones = []
  reasons.each_with_index do |r, i| 
    exclude_phones << OutgoingMessage.completed_with_reason(r)
    exclude_phones = exclude_phones.flatten.uniq

    completed_previous_day = OutgoingMessage.completed_with_reason(reasons[i+1]) unless i+1 == reasons.count
    phones_to_text = (completed_previous_day ? completed_previous_day : []) - exclude_phones

    phones_to_text.each do |p|
      p "texting #{p} - #{messages[i]}"
      OutgoingMessage.send_text_to_number_with_message_and_reason(p, messages[i], r)
    end
  end

  p "done"
  p "*"*50
end
