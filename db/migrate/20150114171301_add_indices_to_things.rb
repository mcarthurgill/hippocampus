class AddIndicesToThings < ActiveRecord::Migration
  def change
    add_index :items, :id
    add_index :items, :user_id

    add_index :buckets, :id
    add_index :buckets, :user_id

    add_index :bucket_item_pairs, :id
    add_index :bucket_item_pairs, :item_id
    add_index :bucket_item_pairs, :bucket_id

    add_index :sms, :id
    add_index :sms, :item_id

    add_index :user, :id
    add_index :user, :phone
  end
end
