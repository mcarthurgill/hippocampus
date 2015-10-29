class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :tag_name
      t.integer :user_id
      t.string :local_key
      t.integer :number_buckets,   :default => 0
      t.string :object_type,   :default => 'tag'

      t.timestamps
    end
  end
end
