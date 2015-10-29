class CreateBucketTagPairs < ActiveRecord::Migration
  def change
    create_table :bucket_tag_pairs do |t|
      t.integer :bucket_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
