class AddMediaCacheToItems < ActiveRecord::Migration
  def change
    add_column :items, :media_cache, :text
  end
end
