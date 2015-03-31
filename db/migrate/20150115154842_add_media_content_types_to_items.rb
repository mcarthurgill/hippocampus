class AddMediaContentTypesToItems < ActiveRecord::Migration
  def change
    add_column :items, :media_content_types, :text
  end
end
