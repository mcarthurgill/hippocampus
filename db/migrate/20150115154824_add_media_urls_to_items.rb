class AddMediaUrlsToItems < ActiveRecord::Migration
  def change
    add_column :items, :media_urls, :text
  end
end
