class AddNameToBucketUserPair < ActiveRecord::Migration
  def change
    add_column :bucket_user_pairs, :name, :string, :default => "You"
  end
end
