class Sm < ActiveRecord::Base

  attr_accessible :AccountSid, :ApiVersion, :Body, :From, :FromCity, :FromCountry, :FromState, :FromZip, :MediaContentTypes, :MediaUrls, :MessageSid, :NumMedia, :SmsMessageSid, :SmsSid, :SmsStatus, :To, :ToCity, :ToCountry, :ToState, :ToZip, :item_id

  extend Formatting
  include Formatting

  serialize :MediaContentTypes, Array
  serialize :MediaUrls, Array
  
  belongs_to :item

  # -- ACTIONS

  def create_item
    i = Item.create_with_sms(self)
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
    msgs = OutgoingMessage.for_phone_with_reason(self.From, "day_1")

    if msgs.count == 1
      self.send_follow_up_text_with_message("Very cool. 2) Where did you meet them?")
    elsif msgs.count == 2
      self.send_follow_up_text_with_message("Awesome. Last question, what is your best friend's birthday?")
    elsif msgs.count == 3
      self.send_follow_up_text_with_message("Whenever you have a thought that you don't want to forget, remember to text Hippocampus. Remember things about people. Show people they matter. To be interesting, be interested.\n\nDownload the app to see and organize your thoughts: https://appsto.re/us/_BWZ5.i\n\nAlso, store this number in your phone and text it any time you don't want to forget a thought.")
    end
  end

  def send_follow_up_text_with_message message
    user = User.find_by_phone(self.From)
    if user && (user.created_at > (Time.zone.now - 6.hours).to_date - 48.hours)
      OutgoingMessage.send_text_to_number_with_message_and_reason(user.phone, message, "day_1")
    end
  end

  # -- HELPERS

  def token_text?
    return self.Body.length > 10 && self.Body.downcase[0...10] == 'my code: (' && self.Body.index('(') && self.Body.index('==')
  end

  def hippo_text?
    u = User.find_by_phone(self.From)
    return self.Body.gsub(/\s+/, "").downcase == "hippo" && u.nil?
  end

  def ignore_text?
    u = User.find_by_phone(self.From)
    return u.nil? || u.created_at > 2.seconds.ago
  end
end
