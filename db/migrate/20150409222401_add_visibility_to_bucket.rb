class AddVisibilityToBucket < ActiveRecord::Migration
  def change
    add_column :buckets, :visibility, :string, :default => "private"
  end
end
