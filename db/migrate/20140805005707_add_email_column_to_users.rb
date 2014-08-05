class AddEmailColumnToUsers < ActiveRecord::Migration
  def change
    add_column :emails, :email, :string
  end
end
