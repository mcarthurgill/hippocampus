class AddItemLocalKeyToMedia < ActiveRecord::Migration
  def change
    add_column :media, :item_local_key, :string
  end
end
