class AddLocalKeyAttributes < ActiveRecord::Migration
  def up
    add_column :users, :local_key, :string
    add_column :items, :local_key, :string
    add_column :buckets, :local_key, :string
  end

  def down
  end
end
