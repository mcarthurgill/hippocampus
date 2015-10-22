class CreateUseCases < ActiveRecord::Migration
  def change
    create_table :use_cases do |t|
      t.text :text
      t.string :image_url
      t.float :order

      t.timestamps
    end
  end
end
