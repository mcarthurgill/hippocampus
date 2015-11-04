class AddLocalKeyToLinks < ActiveRecord::Migration
  def change
    add_column :links, :local_key, :string
  end
end
