class AddDeviceTimestampToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :device_timestamp, :float
  end
end
