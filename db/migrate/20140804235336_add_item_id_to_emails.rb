class AddItemIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :item_id, :integer
  end
end
