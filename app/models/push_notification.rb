class PushNotification < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  attr_accessible :device_token_id, :message, :badge_count, :item_id, :bucket_id, :status


  # --- ASSOCIATIONS

  belongs_to :device_token




  # --- METHODS

  def send_notification
    #determine what type of notification, and send
    if self.device_token.ios_device_token && self.device_token.ios_device_token.length > 0
      send_ios_notification
    elsif self.device_token.android_device_token && self.device_token.android_device_token.length > 0
      send_android_notification
    end
    self.save!
  end


  def send_ios_notification
    self.message = truncate(self.message, length: 160)
    n = Rpush::Apns::Notification.new
    if self.device_token.production?
      n.app = Rpush::Apns::App.find_by_name(ENV['IOS_PRODUCTION_RAPNS'])
    else
      n.app = Rpush::Apns::App.find_by_name(ENV['IOS_DEVELOPMENT_RAPNS'])
    end
    n.device_token = self.device_token.ios_device_token
    n.alert = self.message
    if self.badge_count
      n.badge = self.badge_count
    end
    n.content_available = 1
    if self.item
      n.data = { :object_type => self.item.object_type, :local_key => self.item.local_key }
    elsif self.bucket
      n.data = { :object_type => self.bucket.object_type, :local_key => self.bucket.local_key }
    end
    n.save!
  end


  def send_android_notification
    n = Rpush::Gcm::Notification.new
    n.app = Rpush::Gcm::App.find_by_name(ENV['ANDROID_RAPNS_ENVIRONMENT'])
    n.registration_ids = [self.device_token.android_device_token]
    n.data = {:message => self.message}
    n.save!
  end

end
