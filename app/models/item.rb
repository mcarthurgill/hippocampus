class Item < ActiveRecord::Base
  attr_accessible :message, :person_id, :user_id

  belongs_to :person
  belongs_to :user
end
