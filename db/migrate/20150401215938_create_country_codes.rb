class CreateCountryCodes < ActiveRecord::Migration
  def change
    create_table :country_codes do |t|
      t.string :calling_code
      t.string :country_code

      t.timestamps
    end
  end
end
