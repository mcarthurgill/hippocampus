class CreateAddons < ActiveRecord::Migration
  def change
    create_table :addons do |t|
      t.string :addon_url
      t.string :addon_name

      t.timestamps
    end
  end
end
