class AddLocationIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :longitude
    add_index :items, :latitude
  end
end
