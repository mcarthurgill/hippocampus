class ChangeLinksDatabaseAttrs < ActiveRecord::Migration
  def up
    change_column :links, :best_image, :text
    change_column :links, :favicon, :text
  end

  def down
  end
end
