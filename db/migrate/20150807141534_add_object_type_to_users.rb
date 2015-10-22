class AddObjectTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :object_type, :string, :default => "user"
    add_column :buckets, :object_type, :string, :default => "bucket"
    add_column :bucket_item_pairs, :object_type, :string, :default => "bucket_item_pair"
    add_column :bucket_user_pairs, :object_type, :string, :default => "bucket_user_pair"
    add_column :contact_cards, :object_type, :string, :default => "contact_card"
    add_column :device_tokens, :object_type, :string, :default => "device_token"
    add_column :groups, :object_type, :string, :default => "group"
    add_column :items, :object_type, :string, :default => "item"
    add_column :tokens, :object_type, :string, :default => "token"
  end
end
