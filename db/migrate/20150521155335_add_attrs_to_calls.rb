class AddAttrsToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :action, :string
    add_column :calls, :controller, :string
    add_column :calls, :format, :string
  end
end
