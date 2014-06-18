class User < ActiveRecord::Base
  attr_accessible :phone

  has_many :people
  has_many :items
end
