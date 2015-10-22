class AddDurationToMedia < ActiveRecord::Migration
  def change
    add_column :media, :duration, :float
  end
end
