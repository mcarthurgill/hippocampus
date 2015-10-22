class RemoveBinaryData < ActiveRecord::Migration
  def change
    remove_column :media, :binary_data
  end
end
