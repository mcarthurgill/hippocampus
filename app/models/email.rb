class Email < ActiveRecord::Base

  attr_accessible :Bcc, :Cc, :Date, :From, :FromName, :HtmlBody, :MailboxHash, :MessageID, :ReplyTo, :StrippedTextReply, :Subject, :TextBody, :To, :item_id

  belongs_to :item

end
