class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string :first_name
      t.string :last_name
      t.text :description
      t.integer :user_id

      t.timestamps
    end
  end
end
