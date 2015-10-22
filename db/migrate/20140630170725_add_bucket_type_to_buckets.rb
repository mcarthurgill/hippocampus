class AddBucketTypeToBuckets < ActiveRecord::Migration

  def change
    add_column :buckets, :bucket_type, :string
  end
  
end
