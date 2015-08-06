class AddGroupIdToBucketUserPairs < ActiveRecord::Migration
  def change
    add_column :bucket_user_pairs, :group_id, :integer
  end
end
