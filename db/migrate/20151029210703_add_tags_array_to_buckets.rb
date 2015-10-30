class AddTagsArrayToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :tags_array, :text
  end
end
