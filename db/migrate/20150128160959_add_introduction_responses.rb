class AddIntroductionResponses < ActiveRecord::Migration
  def change
    create_table :introduction_responses do |t|
      t.string :response_text
      t.integer :introduction_question_id
      t.boolean :flagged
      t.timestamps
    end
  end
end
