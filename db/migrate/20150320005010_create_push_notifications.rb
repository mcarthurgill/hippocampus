class CreatePushNotifications < ActiveRecord::Migration
  def change
    create_table :push_notifications do |t|
      t.integer :device_token_id
      t.text :message
      t.integer :badge_count
      t.integer :item_id
      t.integer :bucket_id
      t.string :status

      t.timestamps
    end
  end
end
