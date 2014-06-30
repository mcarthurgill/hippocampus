class AddBucketIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :bucket_id, :integer
  end
end
