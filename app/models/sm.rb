class Sm < ActiveRecord::Base

  attr_accessible :AccountSid, :ApiVersion, :Body, :From, :FromCity, :FromCountry, :FromState, :FromZip, :MessageSid, :NumMedia, :SmsMessageSid, :SmsSid, :SmsStatus, :To, :ToCity, :ToCountry, :ToState, :ToZip, :item_id

  belongs_to :item


  # -- ACTIONS

  def create_item
    i = Item.create_with_sms(self)
    self.update_attribute(:item_id, i.id)
    self.delay(run_at: 1.5.seconds.from_now).concat_if_necessary
    return i
  end

  def concat_if_necessary

    if (self.Body.length == 153 || self.Body.length == 67)
      next_message = Sm.where('id > ? AND created_at < ? AND item_id != ?', self.id, self.created_at + 1.5.seconds, self.item_id).first
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
    if i.id != self.id
      self.item.delete
      self.update_attribute(:item_id, i.id)
      self.delay(run_at: 1.5.seconds.from_now).concat_if_necessary
    end
  end

end
