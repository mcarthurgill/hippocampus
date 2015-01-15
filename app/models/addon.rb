 class Addon < ActiveRecord::Base
  attr_accessible :addon_name, :addon_url

  # --- ASSOCIATIONS
  has_many :tokens

  # --- SCOPES
  scope :daily_j, -> { where("addon_name = ?", "daily_j") }

  # --- CALLBACKS
  after_create :create_api_token

  def create_api_token
    t = Token.with_params(:addon_id => self.id)
    t.assign_token
    t.save
  end
end
