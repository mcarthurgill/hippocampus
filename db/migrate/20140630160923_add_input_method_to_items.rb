class AddInputMethodToItems < ActiveRecord::Migration
  def change
    add_column :items, :input_method, :string
  end
end
