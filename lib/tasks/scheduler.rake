
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




desc "This removes old reminders"
task :remove_old_reminders => :environment do
  p "*"*50
  p "removing old reminders"
  Item.remove_old_reminders
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
    "Day 9 of 9: Curious about the bucket color coding system?\n\nGreen = you have a nudge set within the next 3 weeks.\nBlue = you've added a thought within the last 3 weeks.\nOrange = neither of those are true.\n\nThis is how Katie can see her network at a glance.",
    "Day 8 of 9: Buckets can be collaborative.\n\nThis is how Katie and Will collaborate on their investors bucket: https://youtu.be/56twxZQP8DA (13 second video)",
    "Day 7 of 9: You can assign a thought to multiple buckets.\n\nThis is how Katie organizes her potential investors: https://youtu.be/1qMeeLmNHCo (12 second video)",
    "Day 6 of 9: Hippo lets you search your brain!\n\nThis is how Katie recalls the name of someone when she only remembers where they met: https://youtu.be/NysirbTuosI (6 second video)",
    "Day 5 of 9: Include a date in your thought to automatically create a nudge.\n\nThis is how Katie remembers when her friends are leaving for vacation: https://youtu.be/6bLdWIy8W0M (6 second video)",
    "Day 4 of 9: You can text this number at any time to save a thought.\n\nThis is how Katie jots down names of people she just met: https://youtu.be/RdcfTt_6k4A (8 second video)",
    "Day 3 of 9: Add a thought to a bucket by swiping to the left.\n\nThis is how Katie remembers details about her clients: https://youtu.be/JmfnbRvoTIs (10 second video)",
    "Day 2 of 9: Yesterday was the first day of your nine day tutorial.\n\nDid you know you can swipe right on a thought to set a nudge? This is how Katie remembers great gift ideas: https://youtu.be/nOifntMtnpk (10 second video)"
  ]
  media_urls = [
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042361/color_coding_rtmx9j.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042362/add_collaborator_arfyt3.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042361/multiple_buckets_zfqgob.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042361/search_word_networking_gzhogr.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042362/auto_nudge_eaaaf4.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042362/text_hippo_cnmgqk.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042362/add_to_bucket_a3s1jd.png",
    "http://res.cloudinary.com/hbztmvh3r/image/upload/v1445042362/set_nudge_btuuir.png"
  ]
  reasons = ["day_9", "day_8", "day_7", "day_6", "day_5", "day_4", "day_3", "day_2", "day_1"]
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
      OutgoingMessage.send_text_to_number_with_message_and_reason(p, messages[i], r, media_urls[i])
    end
  end

  p "done"
  p "*"*50
end
