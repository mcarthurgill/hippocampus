class AddTokenTypeToTokens < ActiveRecord::Migration
  def change
    add_column :tokens, :addon_id, :integer
  end
end
