class Email < ActiveRecord::Base

  attr_accessible :Attachments, :Bcc, :Cc, :Date, :From, :FromName, :HtmlBody, :MailboxHash, :MessageID, :ReplyTo, :StrippedTextReply, :Subject, :TextBody, :To, :item_id

  serialize :Attachments, Array

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



  # sending emails

  def self.send_to_user_with_html_and_subject u, html, subject
    self.send_to_users_with_html_and_subject([u], html, subject)
  end

  def self.send_to_users_with_html_and_subject users, html, subject
    m = Mandrill::API.new
    arr = []
    users.each do |u|
      arr << self.to_hash_for_user(u) if u
    end
    message = { 'subject' => subject, 'from_email' => 'note@hppcmps.com', 'from_name' => 'Hippocampus', 'html' => html, 'to' => arr }
    result = m.messages.send message, true, 'Main Pool'
  end

  def self.to_hash_for_user u
    return {'name'=>u.name, 'type'=>'to', 'email'=>u.email}
  end




  # SUNDAY EMAIL

  def self.send_sunday_summaries
    users = [User.find(2)]
    users.each do |u|
      self.send_to_user_with_html_and_subject(u, self.sunday_email_html_for_user(u), "Weekly Thoughts Summary - #{Time.now.strftime('%B %d, %Y')}")
    end
  end

  def self.sunday_email_html_for_user u
    text = ""
    hash = u.items_since_date_sorted_days(7.days.ago)
    hash.each_key do |key|
      text = text+"<p>"
      text = text+"<b>#{key}</b>"
      hash[key].each do |i|
        text = text+"i.message<br>"
      end
      text = text+"</p>"
    end
    return text
  end

end
