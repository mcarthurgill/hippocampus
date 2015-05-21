class AddMissingIndicesToDb < ActiveRecord::Migration
  def change
    add_index :bucket_user_pairs, :bucket_id
    add_index :bucket_user_pairs, :phone_number
    add_index :bucket_user_pairs, :group_id
    add_index :bucket_user_pairs, :id

    add_index :contact_cards, :bucket_id
    add_index :contact_cards, :id

    add_index :device_tokens, :user_id
    add_index :device_tokens, :id

    add_index :emails, :From
    add_index :emails, :To
    add_index :emails, :item_id
    add_index :emails, :id

    add_index :groups, :user_id
    add_index :groups, :id

    add_index :push_notifications, :id

    add_index :tokens, :id
    add_index :tokens, :user_id

    add_index :users, :email
  end
end
