class AddDeviceTimestampToItems < ActiveRecord::Migration
  def change
    add_column :items, :device_timestamp, :string
  end
end
