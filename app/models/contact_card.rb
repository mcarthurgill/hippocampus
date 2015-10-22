class ContactCard < ActiveRecord::Base
  
  attr_accessible :bucket_id, :contact_info, :contact_details, :media_urls, :media_content_types, :object_type

  belongs_to :bucket

  after_create :create_item_for_note

  serialize :media_content_types, Array
  serialize :media_urls, Array

  serialize :contact_details, Hash

  def as_json(options={})
    super(:methods => [:phones, :first_name, :last_name, :name, :record_id, :emails, :note, :birthday, :company])
  end 

  # -- CALLBACKS

  def create_item_for_note
    Item.create_from_contact_card(self) if self.note && self.note.length > 0
  end

  # -- GETTERS
  # CONTACT_INFO IS DEPRECATED
  # use contact_details in SH
  def first_name
    return self.contact_details["first_name"] if self.contact_details
    return JSON.parse(self.contact_info)["first_name"] if self.contact_info
    return nil
  end

  def last_name
    return self.contact_details["last_name"] if self.contact_details
    return JSON.parse(self.contact_info)["last_name"] if self.contact_info
    return nil
  end

  def name
    return self.contact_details["name"] if self.contact_details
    return JSON.parse(self.contact_info)["name"] if self.contact_info
    return nil
  end

  def record_id
    return self.contact_details["record_id"] if self.contact_details
    return JSON.parse(self.contact_info)["record_id"] if self.contact_info
    return nil
  end

  def phones
    return self.contact_details["phones"] if self.contact_details
    return JSON.parse(self.contact_info)["phones"] if self.contact_info
    return nil
  end

  def emails
    return self.contact_details["emails"] if self.contact_details
    return JSON.parse(self.contact_info)["emails"] if self.contact_info
    return nil
  end

  def note
    return self.contact_details["note"] if self.contact_details
    return JSON.parse(self.contact_info)["note"] if self.contact_info
    return nil
  end

  def birthday
    return self.contact_details["birthday"] if self.contact_details
    return JSON.parse(self.contact_info)["birthday"] if self.contact_info
    return nil
  end

  def company
    return self.contact_details["company"] if self.contact_details
    return JSON.parse(self.contact_info)["company"] if self.contact_info
    return nil
  end


  # -- CLOUDINARY

  def upload_main_asset(file, num_uploaded=0)
    public_id = "contact_#{Time.now.to_f}_#{self.bucket_id}"
    url = ""
    
    if !file.is_a?(String) && file.content_type
      self.media_content_types << file.content_type.strip
    end

    url = self.upload_image_to_cloudinary(file, public_id, "jpg") 

    if url && url.length > 0
      self.add_media_url(url)
      return self.media_urls
    end
  end

  def upload_image_to_cloudinary(file, public_id, format)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format, :angle => :exif)
    return data['url'].strip
  end

  def add_media_url url
    if !self.media_urls
      self.media_urls = []
    end
    self.media_urls << url
    return self.media_urls
  end

end
