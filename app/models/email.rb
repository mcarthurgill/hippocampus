class Email < ActiveRecord::Base

  attr_accessible :Bcc, :Cc, :Date, :From, :FromName, :HtmlBody, :MailboxHash, :MessageID, :ReplyTo, :StrippedTextReply, :Subject, :TextBody, :To, :item_id

  belongs_to :item


  def create_item
    i = Item.create_with_email(self)
    self.update_attribute(:item_id, i.id)
    return i
  end

  def parsed_text
    return self.Subject && self.Subject.length > 0 ? "#{self.Subject}\n#{self.body_text}" : self.body_text
  end

  def body_text
    i = self.TextBody.index("\n--")
    return i && i > 0 ? self.TextBody[0,i] : self.TextBody
  end

end
