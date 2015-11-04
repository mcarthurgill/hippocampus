class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :response_status
      t.string :url
      t.string :scheme
      t.string :host
      t.string :root_url
      t.text :title
      t.text :best_title
      t.text :description
      t.text :images
      t.text :images_with_size
      t.string :best_image
      t.string :favicon

      t.timestamps
    end
  end
end
