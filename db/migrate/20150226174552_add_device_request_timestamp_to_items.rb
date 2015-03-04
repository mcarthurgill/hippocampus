class AddDeviceRequestTimestampToItems < ActiveRecord::Migration
  def change
    add_column :items, :device_request_timestamp, :float
  end
end
