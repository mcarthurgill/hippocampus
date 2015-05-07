class RemoveGroupNameFromBucketUserPairs < ActiveRecord::Migration
  def up
    remove_column :bucket_user_pairs, :group_name
  end

  def down
  end
end
