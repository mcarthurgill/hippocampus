class AddMandrillEventsToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :mandrill_events, :text
  end
end
