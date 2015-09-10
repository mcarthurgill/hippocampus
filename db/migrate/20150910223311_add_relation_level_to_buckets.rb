class AddRelationLevelToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :relation_level, :string, :default => 'recent'
  end
end
