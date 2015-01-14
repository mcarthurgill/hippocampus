 class Addon < ActiveRecord::Base
  attr_accessible :addon_name, :addon_url

  # --- ASSOCIATIONS
  has_many :tokens

  # --- SCOPES
  scope :daily_j, -> { where("addon_name = ?", "daily_j") }

  # --- REQUESTS
  def self.send_request_for_user_and_addon_id(user, addon_id)
    token = Token.for_user_and_addon(user.id, addon_id).first
    token ? HTTParty.get("https://daily-j.herokuapp.com/users/#{user.id}", :query => {:id => user.id, :token => token.token_string} ) : nil
  end
end
