class Person < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :location, :user_id

  has_many :items
  belongs_to :user
end
