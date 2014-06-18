class AddItemTypeToItem < ActiveRecord::Migration
  def change
    add_column :items, :item_type, :string
    add_column :items, :reminder_date, :datetime
  end
end
