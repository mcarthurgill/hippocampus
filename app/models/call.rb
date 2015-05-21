class Call < ActiveRecord::Base

  attr_accessible :AccountSid, :ApiVersion, :CallSid, :CallStatus, :Called, :CalledCity, :CalledCountry, :CalledState, :CalledZip, :Caller, :CallerCity, :CallerCountry, :CallerState, :CallerZip, :Digits, :Direction, :From, :FromCity, :FromCountry, :FromState, :FromZip, :RecordingUrl, :RecordingDuration, :RecordingSid, :To, :ToCity, :ToCountry, :ToState, :ToZip, :TranscriptionSid, :TranscriptionText, :TranscriptionStatus, :TranscriptionUrl, :action, :controller, :format, :item_id


  def has_recording?
    return self.RecordingUrl
  end

end
