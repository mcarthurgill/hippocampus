class AddBinaryToMedium < ActiveRecord::Migration
  def change
    add_column :media, :binary_data, :binary
  end
end
