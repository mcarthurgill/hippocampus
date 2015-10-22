class Medium < ActiveRecord::Base

  attr_accessible :duration, :height, :item_local_key, :local_key, :media_extension, :media_name, :media_type, :media_url, :object_type, :thumbnail_url, :transcription_text, :user_id, :width

  belongs_to :item, class_name: 'Item', foreign_key: 'item_local_key', primary_key: 'local_key'
  belongs_to :user






  # -- CALLBACKS

  after_save :update_item_cache
  after_destroy :update_item_cache
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

  before_save :set_defaults
  def set_defaults
    self.local_key ||= "medium-#{Time.now.to_f}-#{self.user_id}" if self.user_id
    self.object_type ||= "medium"
  end




  # -- CREATORS

  def self.create_with_file_user_id_and_item_id file, uid, iid
    medium = Medium.new
    medium.user_id = uid
    medium.item_id = iid
    medium.item_local_key = Item.find(iid).local_key if iid && Item.find(iid)
    medium.upload_main_asset(file)
    medium.save!
    p "*"*50
    puts "Creating directory"
    %x(mkdir tessdir)

    tmp = File.open("tessdir/sample.jpg",'wb')
    tmp.write file

    puts "Starting tesseract"
        %x(tesseract tessdir/sample.jpg tessdir/out.txt -l eng)
        
        puts "Reading result"
        tmp = File.open("tessdir/out.txt", "rb")
        contents = tmp.read
        p "*"*50
        p contents
        puts "removing tessdir"
        %x(rm -Rf tessdir)
        p "*"*50
    # Medium.delay.set_transcription_text(medium.id, file)
    puts medium.as_json().to_s
    return medium
  end

  def self.create_with_file_user_id_item_key_and_local_key file, uid, ik, lk
    medium = Medium.new
    medium.user_id = uid
    medium.item_local_key = ik
    medium.local_key = lk
    medium.upload_main_asset(file)
    medium.save!
    # medium.delay.set_transcription_text(file)
    puts medium.as_json().to_s
    return medium
  end

  def self.create_with_file_and_user_id file, uid
    medium = Medium.new
    medium.user_id = uid
    medium.upload_main_asset(file)
    medium.save!
    # medium.delay.set_transcription_text(file)
    puts medium.as_json().to_s
    return medium
  end

  def self.create_with_call_user_id_and_item_id call, uid, iid
    medium = Medium.new
    medium.user_id = uid
    medium.item_id = iid
    medium.item_local_key = Item.find(iid).local_key if iid && Item.find(iid)
    medium.media_type = 'audio'
    medium.transcription_text = call.TranscriptionText if call.has_transcription?
    medium.media_url = call.RecordingUrl if call.has_recording?
    medium.save!
    return medium
  end






  # -- CLOUDINARY

  def upload_main_asset file
    public_id = "medium_#{Time.now.to_f}_#{self.user_id}"
    self.media_extension = !file.is_a?(String) && file ? file.content_type : "image/jpeg"
    self.determine_media_type

    puts '---UPLOAD METHOD'
    puts self.as_json().to_s

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

  def self.set_transcription_text medium_id, file
    # m = Medium.find(medium_id)
    # img_to_transcribe = RTesseract.new(m.media_name)
    # m.transcription_text = img_to_transcribe.to_s.split("\n").select{|v| v.strip.size > 0}.join(" ")
    # m.save!
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





  def self.convert_all_to_objects
    Item.all.each do |i|
      if i.media_urls.count > 0 && (!i.media || i.media.count == 0)
        skip = false
        i.media_urls.each_with_index do |media_url, index|

          begin

            if !skip #&& i.media_is_image?(index)
              data = Cloudinary::Api.resource(File.basename(URI.parse(media_url).path, ".*"))

              if data
                m = Medium.new
                m.user_id = i.user_id
                m.item_id = i.id
                m.item_local_key = i.local_key
                m.media_extension = "image/jpeg"
                m.determine_media_type

                m.media_url = data["secure_url"]
                m.width = data["width"]
                m.height = data["height"]
                m.media_name = data["public_id"]

                m.save!
              end

            elsif !skip && i.media_is_video?(index)
              data = Cloudinary::Api.resource(File.basename(URI.parse(media_url).path, ".*"), :resource_type => :video)

              if data
                m = Medium.new
                m.user_id = i.user_id
                m.item_id = i.id
                m.item_local_key = i.local_key
                m.media_extension = "image/jpeg"
                m.determine_media_type

                m.media_url = data["secure_url"]
                m.width = data["width"]
                m.height = data["height"]
                m.media_name = data["public_id"]
                m.duration = data["duration"]

                m.thumbnail_url = m.video_thumbnail_url(m.media_url)

                m.save!
              end

              skip = true
            end

            puts "completed for: #{i.id}"

          rescue
            puts "exception rescued for item: #{i.id}"

          end

        end
      end
    end
  end


end
