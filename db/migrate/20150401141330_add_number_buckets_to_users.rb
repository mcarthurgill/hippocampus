class AddNumberBucketsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :number_buckets, :integer, :default => 0
  end
end
