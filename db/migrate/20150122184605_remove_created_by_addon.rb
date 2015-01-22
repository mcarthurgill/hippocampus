class RemoveCreatedByAddon < ActiveRecord::Migration
  def change
    remove_column :buckets, :created_by_addon
  end
end
