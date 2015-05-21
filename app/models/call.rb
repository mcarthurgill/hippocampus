class Call < ActiveRecord::Base

  attr_accessible :AccountSid, :ApiVersion, :CallSid, :CallStatus, :Called, :CalledCity, :CalledCountry, :CalledState, :CalledZip, :Caller, :CallerCity, :CallerCountry, :CallerState, :CallerZip, :Digits, :Direction, :From, :FromCity, :FromCountry, :FromState, :FromZip, :RecordingUrl, :RecordingDuration, :RecordingSid, :To, :ToCity, :ToCountry, :ToState, :ToZip, :TranscriptionSid, :TranscriptionText, :TranscriptionStatus, :TranscriptionUrl, :action, :controller, :format, :item_id

  belongs_to :item

  after_create :create_item_if_should
  def create_item_if_should
    self.create_item if self.should_create_item?
  end


  def should_create_item?
    return self.has_recording?
  end

  def has_recording?
    return self.RecordingUrl
  end

  def has_transcription?
    return self.TranscriptionText && self.TranscriptionStatus == 'completed'
  end

  def create_item
    i = Item.create_with_call(self)
    self.update_attribute(:item_id, i.id) if i.id
    return i
  end

  def update_item_with_transcription
    if self.item
      self.item.assign_attributes(message: self.TranscriptionText) if self.has_transcription?
      self.item.check_for_and_set_date if !self.item.reminder_date
      self.item.save!
    end
  end

end
