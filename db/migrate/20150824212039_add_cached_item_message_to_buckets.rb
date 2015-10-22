class AddCachedItemMessageToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :cached_item_message, :string
  end
end
