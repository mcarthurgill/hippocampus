class AddItemIdToSms < ActiveRecord::Migration
  def change
    add_column :sms, :item_id, :integer
  end
end
