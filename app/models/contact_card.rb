class ContactCard < ActiveRecord::Base
  attr_accessible :bucket_id, :contact_info, :media_urls, :media_content_types

  belongs_to :bucket

  after_create :create_item_for_note

  serialize :media_content_types, Array
  serialize :media_urls, Array

  def as_json(options={})
    super(:methods => [:phones, :first_name, :last_name, :name, :record_id, :emails, :note, :birthday, :company])
  end 

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


  # -- CLOUDINARY

  def upload_main_asset(file, num_uploaded=0)
    public_id = "contact_#{Time.now.to_f}_#{self.user_id}"
    url = ""
    
    if !file.is_a?(String) && file.content_type
      self.media_content_types << file.content_type
    end

    url = self.upload_image_to_cloudinary(file, public_id, "jpg") 

    if url && url.length > 0
      self.add_media_url(url)
      return self.media_urls
    end
  end

  def upload_image_to_cloudinary(file, public_id, format)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format, :angle => :exif)
    return data['url']
  end

  def add_media_url url
    if !self.media_urls
      self.media_urls = []
    end
    self.media_urls << url
    return self.media_urls
  end

end
