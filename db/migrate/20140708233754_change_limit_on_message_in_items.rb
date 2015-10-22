class ChangeLimitOnMessageInItems < ActiveRecord::Migration
  def up
    change_column :items, :message, :text, :limit => nil
  end

  def down
  end
end
