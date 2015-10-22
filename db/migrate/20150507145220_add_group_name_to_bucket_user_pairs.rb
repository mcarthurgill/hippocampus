class AddGroupNameToBucketUserPairs < ActiveRecord::Migration
  def change
    add_column :bucket_user_pairs, :group_name, :string
  end
end
