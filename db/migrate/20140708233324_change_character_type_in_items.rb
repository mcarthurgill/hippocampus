class ChangeCharacterTypeInItems < ActiveRecord::Migration
  def up
    change_column :items, :message, :text
  end

  def down
    change_column :items, :message, :string
  end
end
