class ChangeUserIdToPhoneNumberOnBup < ActiveRecord::Migration
  def change
    remove_column :bucket_user_pairs, :user_id
    add_column :bucket_user_pairs, :phone_number, :string
  end
end
