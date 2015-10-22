class AddLocalKeyToMedia < ActiveRecord::Migration
  def change
    add_column :media, :local_key, :string
  end
end
