class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :message
      t.string :person_id
      t.string :user_id

      t.timestamps
    end
  end
end
