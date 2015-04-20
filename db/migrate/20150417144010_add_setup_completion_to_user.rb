class AddSetupCompletionToUser < ActiveRecord::Migration
  def change
    add_column :users, :setup_completion, :integer, :default => 25
  end
end
