class Medium < ActiveRecord::Base

  attr_accessible :duration, :height, :item_id, :media_extension, :media_name, :media_type, :media_url, :thumbnail_url, :user_id, :width

  belongs_to :item
  belongs_to :user






  # -- CALLBACKS

  after_save :update_item_cache
  def update_item_cache
    self.item.update_media_cache if self.item
  end

  after_create :legacy_support
  def legacy_support
    if self.item && self.media_url
      self.item.add_media_url(self.media_url)
      self.item.add_media_url(self.thumbnail_url) if self.is_video?
      self.item.save!
    end
  end





  # -- CREATORS

  def self.create_with_file_user_id_and_item_id file, uid, iid
    medium = Medium.new
    medium.user_id = uid
    medium.item_id = iid
    medium.upload_main_asset(file)
    medium.save!
    puts '---CREATE METHOD'
    puts medium.to_s
    return medium
  end






  # -- CLOUDINARY

  def upload_main_asset file
    public_id = "medium_#{Time.now.to_f}_#{self.user_id}"

    self.media_extension = file.content_type
    self.media_type = self.determine_media_type

    puts '---UPLOAD METHOD'
    puts self.to_s

    if self.is_image?
      data = self.upload_image_to_cloudinary(file, public_id, "jpg")
      puts '---IS IMAGE METHOD'
      puts data
      if data
        self.media_url = data["secure_url"]
        self.width = data["width"]
        self.height = data["height"]
        self.media_name = data["public_id"]
      end
    elsif self.is_video?
      data = self.upload_video_to_cloudinary(file, public_id)
      if data
        self.media_url = data["secure_url"]
        self.width = data["width"]
        self.height = data["height"]
        self.media_name = data["public_id"]
        self.duration = data["duration"]

        self.thumbnail_url = self.video_thumbnail_url(self.media_url)
      end
    end

    return self.media_url
  end

  def determine_media_type
    self.media_type = 'image' if ["image/jpeg", "image/png", "image/jpg"].include?(self.media_extension)
    self.media_type = 'video' if ["video/3gpp", "video/mov", "video/quicktime"].include?(self.media_extension)
    self.media_type = 'undetermined' if !self.media_type
  end

  def is_image?
    return self.media_type == 'image'
  end

  def is_video?
    return self.media_type == 'video'
  end


  def upload_image_to_cloudinary(file, public_id, format)
    return Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format, :angle => :exif)
  end

  def upload_video_to_cloudinary(file, public_id)
    return Cloudinary::Uploader.upload(file, :public_id => public_id, :resource_type => :video)
  end


  def video_thumbnail_url url
    string_to_locate = "/upload/"
    beginning_index = url.index(string_to_locate)
    extension_index = url.index("." + url.split(".").last)
    rest_of_url = url[(beginning_index + string_to_locate.length)...extension_index]

    thumbnail_url = "l_playButton/" + rest_of_url + ".png"
    return thumbnail_url.insert(0, url[0...beginning_index + string_to_locate.length])
  end



end
