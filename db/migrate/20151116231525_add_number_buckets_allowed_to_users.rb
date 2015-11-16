class AddNumberBucketsAllowedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :number_buckets_allowed, :integer
  end
end
