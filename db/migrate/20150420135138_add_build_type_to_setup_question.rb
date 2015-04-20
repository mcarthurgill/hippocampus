class AddBuildTypeToSetupQuestion < ActiveRecord::Migration
  def change
    add_column :setup_questions, :build_type, :string
  end
end
