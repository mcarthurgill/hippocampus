class AddObjectTypeToLinks < ActiveRecord::Migration
  def change
    add_column :links, :object_type, :string, :default => 'link'
  end
end
