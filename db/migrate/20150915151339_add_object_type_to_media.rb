class AddObjectTypeToMedia < ActiveRecord::Migration
  def change
    add_column :media, :object_type, :string, :default => 'medium'
  end
end
