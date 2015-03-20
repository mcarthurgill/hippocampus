class PushNotification < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  attr_accessible :book_identifier, :device_token_id, :message, :push_notification_type, :status, :post_id, :environment, :topic_id




  # --- ASSOCIATIONS

  belongs_to :device_token
  belongs_to :post




  # --- METHODS

  def send_notification
    #determine what type of notification, and send
    if self.device_token.ios_device_token && self.device_token.ios_device_token.length > 0 && self.device_token.current?
      #send ios
      send_ios_notification
    end
    if self.device_token.android_device_token && self.device_token.android_device_token.length > 0 && self.device_token.current?
        #send android
        send_android_notification
    end
  end


  def send_ios_notification

    self.message = truncate(self.message, length: 160)

    n = Rpush::Apns::Notification.new
    if self.device_token.environment == "production"
      n.app = Rpush::Apns::App.find_by_name(ENV['IOS_PRODUCTION_RAPNS_ENVIRONMENT'])
    else
      n.app = Rpush::Apns::App.find_by_name(ENV['IOS_RAPNS_ENVIRONMENT'])
    end
    n.device_token = self.device_token.ios_device_token
    n.alert = self.message
    # if self.device_token.user
      n.badge = 1 # self.device_token.user.likes_for_post(self.post_id)
    # end
    n.content_available = 1
    if self.book_identifier
      n.attributes_for_device = { :post_id => self.post_id, :user_id => self.device_token.user_id, :bid => self.book_identifier }
    else
      n.attributes_for_device = { :post_id => self.post_id, :user_id => self.device_token.user_id }
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
