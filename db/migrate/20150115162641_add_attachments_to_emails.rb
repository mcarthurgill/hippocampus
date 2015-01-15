class AddAttachmentsToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :Attachments, :text
  end
end
