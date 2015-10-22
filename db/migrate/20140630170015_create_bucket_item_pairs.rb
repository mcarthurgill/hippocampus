class CreateBucketItemPairs < ActiveRecord::Migration
  def change
    create_table :bucket_item_pairs do |t|
      t.integer :bucket_id
      t.integer :item_id

      t.timestamps
    end
  end
end
