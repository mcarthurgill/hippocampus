class ContactCard < ActiveRecord::Base
  attr_accessible :bucket_id, :contact_info

  belongs_to :bucket

  # -- GETTERS
  def first_name
    JSON.parse(self.contact_info)["first_name"]
  end

  def last_name
    JSON.parse(self.contact_info)["last_name"]
  end

  def name
    JSON.parse(self.contact_info)["name"]
  end

  def record_id
    JSON.parse(self.contact_info)["record_id"]
  end

  def phones
    JSON.parse(self.contact_info)["phones"]
  end

  def emails
    JSON.parse(self.contact_info)["emails"]
  end
end
