class AddParentIdToSetupQuestion < ActiveRecord::Migration
  def change
    add_column :setup_questions, :parent_id, :integer
  end
end
