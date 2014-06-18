class User < ActiveRecord::Base
  attr_accessible :phone, :country_code

  has_many :people
  has_many :items
end
