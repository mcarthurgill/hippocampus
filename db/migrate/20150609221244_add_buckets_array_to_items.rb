class AddBucketsArrayToItems < ActiveRecord::Migration
  def change
    add_column :items, :buckets_array, :text
  end
end
