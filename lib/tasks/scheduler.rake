
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
      message = "You have pending thoughts on Hippocampus. Open the app to handle them."
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





desc "7 day tutorial"
task :seven_day_tutorial => :environment do
  p "*"*50
  p "texting users going through the tutorial"

  messages = [
    "Day 7 of 7: \"About 15% of one's financial success is due to one's technical knowledge and about 85% is due to skill in human engineering - to personality and the ability to lead people.\" \n\nSuccessful people write things down. Today, ask a coworker about their ambitions and put it into your Hippocampus.",
    "Day 6 of 7: \"Talk to someone about themselves and they'll listen for hours.\" \n\nThis afternoon, text a friend how their job is going and store their answer in your Hippocampus.",
    "Day 5 of 7: \"Information not found in notes has just a 5% chance of being remembered.\" \n\nStore a thought that surprises or interests you today in your Hippocampus.",
    "Day 4 of 7: \"We are interested in others when they are interested in us.\" \n\nAsk a friend what their favorite restaurant is and text it to your Hippocampus.",
    "Day 3 of 7: \"A person's name is to that person the sweetest and most important sound in any language.\" \n\nToday, store in your Hippocampus the name of the first new person you meet.",
    "Day 2 of 7: Yesterday you completed the first day of your seven day tutorial. Build a habit of storing thoughts in your Hippocampus to show people they matter. \n\nToday, text your Hippocampus something you learn about a friend or a coworker."
  ]
  reasons = ["day_7", "day_6", "day_5", "day_4", "day_3", "day_2", "day_1"]
  exclude_phones = []
  reasons.each_with_index do |r, i| 
    exclude_phones << OutgoingMessage.completed_with_reason(r)
    exclude_phones = exclude_phones.flatten.uniq
    p exclude_phones
    p "*"*50

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
