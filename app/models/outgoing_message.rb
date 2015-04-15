class OutgoingMessage < ActiveRecord::Base

  attr_accessible :from_number, :message, :reason, :to_number, :media_url

  def self.send_text_to_number_with_message_and_reason to_num, m, r, med_url=nil
    o = OutgoingMessage.new(to_number: to_num, message: m, reason: r)
    o.media_url = med_url if med_url
    o.determine_from_number(to_num)
    o.save
    o.send_text
  end

  def send_text
    begin
      client = Twilio::REST::Client.new(Hippocampus::Application.config.account_sid, Hippocampus::Application.config.auth_token)
      account = client.account
      if self.message && self.message.length > 1600
        self.send_split_texts(account)
      else
        account.messages.create({:body => self.message, :to => append_plus_to_number(self.to_number), :from => append_plus_to_number(self.from_number), :media_url => self.media_url})
      end    
    rescue Twilio::REST::RequestError => e
      p e.message
    end
  end

  def send_split_texts account
    message_string = ""
    split_words = self.message.split(" ")
    split_words.each_with_index do |w, i|
      if message_string.length + w.length + 1 < 1600 #added 1 for the space
        message_string << w + " "
        if i == split_words.count - 1 #last word
          account.messages.create({:body => message_string, :to => append_plus_to_number(self.to_number), :from => self.from_number, :media_url => self.media_url})  
        end
      else
        account.messages.create({:body => message_string, :to => append_plus_to_number(self.to_number), :from => self.from_number, :media_url => self.media_url})
        message_string = w + " "
      end
    end
  end

  def append_plus_to_number(number)
    number.first == "+" ? number : number.prepend("+")
  end

  def determine_from_number(number)
    if number.slice(0..1) == '44' || number.slice(0..2) == '+44'
      self.from_number = "+441526201043"
    else
      self.from_number = "+16157249333"
    end
    return self.from_number
  end



  # -- TUTORIAL

  def self.completed_with_reason r
    OutgoingMessage.where("reason = ? AND created_at < ?", r, Time.zone.now.to_date).pluck(:to_number).uniq #exclude users created today
  end
  
end
