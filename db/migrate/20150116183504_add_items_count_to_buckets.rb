class AddItemsCountToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :items_count, :integer, :default => 0
  end
end
