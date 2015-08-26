class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.string :media_url
      t.integer :width
      t.integer :height
      t.string :media_type
      t.string :media_extension
      t.string :media_name
      t.integer :user_id
      t.integer :item_id
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
