class IntroductionQuestion < ActiveRecord::Base
  attr_accessible :question_text, :status

  # --- ASSOCIATIONS
  has_many :introduction_responses
  

  # --- SCOPES
  scope :live_with_responses, -> { where("status = ?", "live").order("created_at ASC").includes(:introduction_responses) }

end
