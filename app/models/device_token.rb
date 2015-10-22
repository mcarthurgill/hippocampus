class DeviceToken < ActiveRecord::Base

  attr_accessible :android_device_token, :environment, :ios_device_token, :user_id, :object_type

  belongs_to :user
  has_many :push_notifications


  def production?
    self.environment == 'production'
  end

  def development?
    self.environment == 'development'
  end

end
