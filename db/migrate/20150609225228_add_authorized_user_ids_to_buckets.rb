class AddAuthorizedUserIdsToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :authorized_user_ids, :text
  end
end
