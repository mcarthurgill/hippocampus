class Addon < ActiveRecord::Base
  attr_accessible :addon_name, :addon_url

  # --- ASSOCIATIONS
  has_many :tokens

  # --- SCOPES
  scope :daily_j, -> { where("addon_name = ?", "daily_j") }

end
