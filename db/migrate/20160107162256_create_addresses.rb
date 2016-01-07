class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :phone
      t.string :street
      t.string :street_two
      t.string :city
      t.string :state
      t.string :zip
      t.string :object_type
      t.string :local_key

      t.timestamps
    end
  end
end
