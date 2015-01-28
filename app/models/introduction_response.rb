class IntroductionResponse < ActiveRecord::Base
  attr_accessible :introduction_question_id, :response_text, :flagged

  # --- ASSOCIATIONS
  belongs_to :introduction_question
  
  # --- HELPERS
  def flagged?
      self.flagged
  end  
end

