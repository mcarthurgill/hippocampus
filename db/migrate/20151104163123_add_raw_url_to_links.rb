class AddRawUrlToLinks < ActiveRecord::Migration
  def change
    add_column :links, :raw_url, :string
  end
end
