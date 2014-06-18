desc "This texts all users who have outstanding items"
task :send_reminders => :environment do
  p "*"*50
  p "texting users"
  User.remind_about_outstanding_items
  p "done"
  p "*"*50
end
