class CreateBucketUserPairs < ActiveRecord::Migration
  def change
    create_table :bucket_user_pairs do |t|
      t.integer :bucket_id
      t.integer :user_id

      t.timestamps
    end
  end
end
