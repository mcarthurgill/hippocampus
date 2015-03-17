class DeviceToken < ActiveRecord::Base
  attr_accessible :android_device_token, :environment, :ios_device_token, :user_id

  belongs_to :user
end
