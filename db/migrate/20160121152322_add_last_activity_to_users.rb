class AddLastActivityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_activity, :datetime, :default => DateTime.now
  end
end
