class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :group_name
      t.integer :user_id
      t.integer :number_buckets, :default => 0

      t.timestamps
    end
  end
end
