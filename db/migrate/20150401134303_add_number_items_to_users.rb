class AddNumberItemsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :number_items, :integer, :default => 0
  end
end
