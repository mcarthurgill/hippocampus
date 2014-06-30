class Sm < ActiveRecord::Base

  attr_accessible :AccountSid, :ApiVersion, :Body, :From, :FromCity, :FromCountry, :FromState, :FromZip, :MessageSid, :NumMedia, :SmsMessageSid, :SmsSid, :SmsStatus, :To, :ToCity, :ToCountry, :ToState, :ToZip, :item_id


  # -- ACTIONS

  def create_item
    i = Item.create_with_sms(self)
    self.item_id = i.id
    return i
  end

end
