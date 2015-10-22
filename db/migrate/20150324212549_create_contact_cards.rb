class CreateContactCards < ActiveRecord::Migration
  def change
    create_table :contact_cards do |t|
      t.integer :bucket_id
      t.text :contact_info

      t.timestamps
    end
  end
end
