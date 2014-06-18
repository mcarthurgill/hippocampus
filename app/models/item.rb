class Item < ActiveRecord::Base
  attr_accessible :message, :person_id, :user_id, :item_type, :reminder_date

  belongs_to :person
  belongs_to :user
end
