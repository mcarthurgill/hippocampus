class Sm < ActiveRecord::Base

  attr_accessible :AccountSid, :ApiVersion, :Body, :From, :FromCity, :FromCountry, :FromState, :FromZip, :MediaContentTypes, :MediaUrls, :MessageSid, :NumMedia, :SmsMessageSid, :SmsSid, :SmsStatus, :To, :ToCity, :ToCountry, :ToState, :ToZip, :item_id

  serialize :MediaContentTypes, Array
  serialize :MediaUrls, Array
  
  belongs_to :item

  # -- ACTIONS

  def create_item
    i = Item.create_with_sms(self)
    self.delay.should_send_follow_up_texts
    self.update_attribute(:item_id, i.id)
    self.delay(run_at: 1.5.seconds.from_now).concat_if_necessary
    return i
  end

  def add_media_if_present params
    count = self.NumMedia.to_i
    self.MediaContentTypes = []
    self.MediaUrls = []
    count.times do |i|
      self.MediaContentTypes << params["MediaContentType#{i}"]
      self.MediaUrls << params["MediaUrl#{i}"]
    end
  end

  def concat_if_necessary

    if (self.Body.length == 153 || self.Body.length == 67)
      next_message = Sm.where('id > ? AND created_at < ? AND item_id != ?', self.id, self.created_at + 1.5.seconds, self.item_id).order('created_at ASC').first
      if next_message
        # needs to concat. append that message to this item, delete that item, and then update that sm's item and try to concat again
        if self.item
          self.item.update_attribute(:message, "#{self.item.message}#{next_message.Body}")
          next_message.concatted_to_item(self.item)
        end
      end
    end
  end

  def concatted_to_item i
    # delete the current item (if different from concatted to item), then update the item to the input item, then try concatting
    if i.id != self.item_id
      self.item.delete
      self.update_attribute(:item_id, i.id)
      self.delay(run_at: 1.5.seconds.from_now).concat_if_necessary
    end
  end

  def should_send_follow_up_texts
    number_texts = Sm.where(:From => self.From).count
    if number_texts == 2
      self.send_follow_up_text_with_message("Very cool. Another question, what are the names of your best friend's parents?")
    elsif number_texts == 3
      self.send_follow_up_text_with_message("Awesome. Last question, who was the last person you met and what did you learn about them?")
    elsif number_texts == 4
      self.send_follow_up_text_with_message("Whenever you have a thought that you don't want to forget, remember to text Hippocampus. Remembering details makes all the difference in the world.\n\nDownload the app to see and organize your notes: http://hppcmps.com/")
    end
  end

  def send_follow_up_text_with_message message
    user = User.where("phone = ?", self.From).first
    if user && (user.created_at > Date.today - 48.hours)
      OutgoingMessage.send_text_to_number_with_message_and_reason(user.phone, message, "tutorial")
    end
  end

  def self.create_blank_if_none(user)
    if Sm.where(:From => user.phone).count == 0
      Sm.create(:From => user.phone)
    end
  end

end
