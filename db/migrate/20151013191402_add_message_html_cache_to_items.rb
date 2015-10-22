class AddMessageHtmlCacheToItems < ActiveRecord::Migration
  def change
    add_column :items, :message_html_cache, :text
  end
end
