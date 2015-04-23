class AddSomeAttrsToBucketUserPairs < ActiveRecord::Migration
  def change
    add_column :bucket_user_pairs, :last_viewed, :datetime
    add_column :bucket_user_pairs, :unseen_items, :string, :default => 'no'
  end
end
