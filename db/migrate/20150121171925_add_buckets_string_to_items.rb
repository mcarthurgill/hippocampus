class AddBucketsStringToItems < ActiveRecord::Migration
  def change
    add_column :items, :buckets_string, :text
  end
end
