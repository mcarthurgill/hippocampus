class AddLinksToItems < ActiveRecord::Migration
  def change
    add_column :items, :links, :text
  end
end
