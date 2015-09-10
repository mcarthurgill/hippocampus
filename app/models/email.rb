class Email < ActiveRecord::Base

  extend Formatting
  include Formatting

  attr_accessible :Attachments, :Bcc, :Cc, :Date, :From, :FromName, :HtmlBody, :MailboxHash, :MessageID, :ReplyTo, :StrippedTextReply, :Subject, :TextBody, :To, :item_id, :mandrill_events

  serialize :Attachments, Array
  serialize :mandrill_events, JSON

  belongs_to :item

  belongs_to :user, :class_name => "User", :foreign_key => "From", :primary_key => "email"


  def create_item
    i = Item.create_with_email(self)
    self.update_attribute(:item_id, i.id)
    return i
  end

  def parsed_text
    return self.Subject && self.Subject.length > 0 ? "#{self.Subject}\n#{self.body_text.cut_off_signatures_and_replies}" : self.body_text.cut_off_signatures_and_replies
  end

  def body_text
    i = self.TextBody.index("\n--")
    t = i && i > 0 ? self.TextBody[0,i] : self.TextBody
    return t.gsub /(?<!\n)\n(?!\n)/, ' '
  end

  def self.save_inbound_mail(event_payload)
    # puts event_payload
    e = Email.new
    e.mandrill_events = event_payload
    e.TextBody = e.mandrill_events["msg"]["text"]
    e.HtmlBody = e.mandrill_events["msg"]["html"]
    e.From = e.mandrill_events["msg"]["from_email"].downcase.strip
    e.FromName = e.mandrill_events["msg"]["from_name"]
    e.To = e.mandrill_events["msg"]["email"]
    e.Subject = e.mandrill_events["msg"]["subject"]
    e.save!
    return e
  end

  def handle_email
    if self.user
      # create item
      self.create_item
      self.user.save! if self.user.set_name(self.FromName)
    elsif self.Subject && self.Subject.length > 40 && self.Subject[0..9] == 'My Token: '
      # find user based on token and uid
      token = token_for_verification_text(self.Subject)
      user_id = user_id_for_verification_text(self.Subject).to_i
      u = User.find_by_id(user_id)
      if u && u.validate_with_token(token)
        # belongs to user
        u.update_attribute(:email, self.From)
      end
    end
  end

  def handle_attachments attaches
    self.Attachments = attaches
    self.save!
  end



  # sending emails

  def self.send_to_user_with_html_and_subject u, html, subject
    self.send_to_users_with_html_and_subject([u], html, subject)
  end

  def self.send_to_users_with_html_and_subject users, html, subject
    require 'mandrill'
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
    users = [User.find(2), User.find(23)]
    users.each do |u|
      self.send_to_user_with_html_and_subject(u, self.sunday_email_html_for_user(u), "Weekly Notes Summary - #{Time.now.strftime('%B %d, %Y')}")
    end
  end

  def self.send_daily_summaries
    users = [User.find(2), User.find(23)]
    users.each do |u|
      self.send_to_user_with_html_and_subject(u, self.daily_email_html_for_user(u), "#{1.day.ago.strftime('%A')}'s Notes Summary (#{1.day.ago.strftime('%B %d')})")
    end
  end

  def self.sunday_email_html_for_user u
    text = "Your weekly Hippocampus notes summary. Enjoy!<br><br>"
    hash = u.items_since_date_sorted_days(6.days.ago)
    hash.each_key do |key|
      text = text+"<p>"
      text = text+"<h2>#{key}</h2><br>"
      hash[key].each do |i|
        if i.media_urls
          i.media_urls.each do |url|
            url = url.sub('upload/', 'upload/c_scale,w_320/')
            text = text+"<img src='#{url}'><br>"
          end
        end
        text = text+"#{i.message}<br>"
        if i.buckets_string
          text = text+"<i>-#{i.buckets_string}</i>"
        else
          text = text+"<i>-Unassigned</i>"
        end
        text = text+"<br><br>"
      end
      text = text+"</p><br>"
    end
    return text
  end

  def self.daily_email_html_for_user u
    text = "Yesterday's Hippocampus notes summary. Enjoy!<br><br>"
    hash = u.yesterdays_items_sorted_days
    hash.each_key do |key|
      text = text+"<p>"
      text = text+"<h2>#{key}</h2><br>"
      hash[key].each do |i|
        if i.media_urls
          i.media_urls.each do |url|
            url = url.sub('upload/', 'upload/c_scale,w_320/')
            text = text+"<img src='#{url}'><br>"
          end
        end
        text = text+"#{i.message}<br>"
        if i.buckets_string
          text = text+"<i>-#{i.buckets_string}</i>"
        else
          text = text+"<i>-Unassigned</i>"
        end
        text = text+"<br><br>"
      end
      text = text+"</p><br>"
    end
    return text
  end

end

