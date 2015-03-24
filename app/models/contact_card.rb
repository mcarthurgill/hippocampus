class ContactCard < ActiveRecord::Base
  attr_accessible :bucket_id, :contact_info

  belongs_to :bucket
end
