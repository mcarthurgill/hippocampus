class Person < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :location

  has_many :items
end
