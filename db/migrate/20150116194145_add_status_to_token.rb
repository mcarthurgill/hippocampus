class AddStatusToToken < ActiveRecord::Migration
  def change
    add_column :tokens, :status, :string, :default => "live"
  end
end
