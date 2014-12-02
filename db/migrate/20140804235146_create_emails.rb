class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :From
      t.string :FromName
      t.string :To
      t.text :Cc
      t.text :Bcc
      t.string :ReplyTo
      t.text :Subject
      t.string :MessageID
      t.string :Date
      t.text :MailboxHash
      t.text :TextBody
      t.text :HtmlBody
      t.text :StrippedTextReply

      t.timestamps
    end
  end
end
