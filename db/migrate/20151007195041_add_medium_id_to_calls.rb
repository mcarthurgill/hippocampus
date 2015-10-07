class AddMediumIdToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :medium_id, :integer
  end
end
