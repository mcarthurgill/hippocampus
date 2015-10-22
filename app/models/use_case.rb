class UseCase < ActiveRecord::Base
  attr_accessible :image_url, :order, :text

  def upload_main_asset(file)
    public_id = "uc_#{Time.now.to_f}_admin"
    url = self.upload_image_to_cloudinary(file, public_id, 'jpg')
    if url && url.length > 0
      return self.update_attribute(:image_url, url)
    end
  end

  def upload_image_to_cloudinary(file, public_id, format)
    data = Cloudinary::Uploader.upload(file, :public_id => public_id, :format => format)
    return data['url']
  end

end
