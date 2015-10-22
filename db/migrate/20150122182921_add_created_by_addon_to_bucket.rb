class AddCreatedByAddonToBucket < ActiveRecord::Migration
  def change
    add_column :buckets, :created_by_addon, :boolean, :default => false
  end
end
