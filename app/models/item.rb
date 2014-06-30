class Item < ActiveRecord::Base

  attr_accessible :message, :person_id, :user_id, :item_type, :reminder_date, :status, :input_method


  # -- RELATIONSHIPS

  belongs_to :user


  # -- SCOPES

  scope :outstanding, -> { where("status = ?", "outstanding").includes(:user) } 
  scope :events_for_today, -> { where("item_type = ? AND reminder_date = ?", "event", Date.today).includes(:user) } 


  # -- SETTERS

  def set_attrs_from_twilio(message, phone_number, item_type)
    self.message = message
    self.user = User.find_by_phone(phone_number)
    self.item_type = item_type
  end
  
end
