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


  # --- QUERY
  def self.for_addon_name_and_token(name, token)
    addon = Addon.where("addon_name = ?", name).first
    if addon
      t = Token.for_addon(addon.id).first
      if t.token_string == token
        return addon
      end
    end
    return nil
  end
end
