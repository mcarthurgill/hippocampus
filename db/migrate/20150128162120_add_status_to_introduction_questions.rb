class AddStatusToIntroductionQuestions < ActiveRecord::Migration
  def change
    add_column :introduction_questions, :status, :string, :default => "live"
  end
end
