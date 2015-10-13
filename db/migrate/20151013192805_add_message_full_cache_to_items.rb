class AddMessageFullCacheToItems < ActiveRecord::Migration
  def change
    add_column :items, :message_full_cache, :text
  end
end
