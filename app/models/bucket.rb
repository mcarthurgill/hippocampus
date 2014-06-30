class Bucket < ActiveRecord::Base

  attr_accessible :description, :first_name, :last_name, :user_id

  belongs_to :user

end
