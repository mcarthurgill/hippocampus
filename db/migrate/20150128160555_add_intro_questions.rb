class AddIntroQuestions < ActiveRecord::Migration
  def change
    create_table :introduction_questions do |t|
      t.string :question_text
      t.timestamps
    end
  end
end
