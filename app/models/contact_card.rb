class ContactCard < ActiveRecord::Base
  attr_accessible :bucket_id, :contact_info

  belongs_to :bucket

  after_create :create_item_for_note

  # -- CALLBACKS

  def create_item_for_note
    Item.create_from_contact_card(self) if self.note
  end

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

  def note
    JSON.parse(self.contact_info)["note"]
  end

  def birthday
    JSON.parse(self.contact_info)["birthday"]
  end

  def company
    JSON.parse(self.contact_info)["company"]
  end
end
