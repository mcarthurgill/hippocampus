class AddMediaUrlsToContactCard < ActiveRecord::Migration
  def change
    add_column :contact_cards, :media_urls, :text
    add_column :contact_cards, :media_content_types, :text
  end
end
