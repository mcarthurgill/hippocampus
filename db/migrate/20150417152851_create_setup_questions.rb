class CreateSetupQuestions < ActiveRecord::Migration
  def change
    create_table :setup_questions do |t|
      t.string :question
      t.integer :percentage

      t.timestamps
    end
  end
end
