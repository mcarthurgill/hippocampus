class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :message
      t.integer :person_id
      t.integer :user_id

      t.timestamps
    end
  end
end
