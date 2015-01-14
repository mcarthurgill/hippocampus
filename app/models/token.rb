class Token < ActiveRecord::Base

  # --- ATTRIBUTES
  attr_accessible :token_string, :user_id, :addon_id

  # --- ASSOCIATIONS
  belongs_to :user
  belongs_to :addon

  # --- SCOPES
  scope :live, ->{ where('created_at > ?', 5.minutes.ago) }
  scope :match, ->(token_string, user_id, addon_id) { where({:token_string => token_string, :user_id => user_id, :addon_id => addon_id}) }
  scope :for_user_and_addon, ->(user_id, addon_id) { where("user_id = ? AND addon_id = ?", user_id, addon_id) }

  # --- CREATION
  def self.with_params params
    token = Token.new(params)
    return token
  end

  def assign_token
    if self.addon
      self.token_string = SecureRandom.hex  
    else
      self.token_string = "#{Random.new.rand(1111...9999)}"[0..3]
    end
  end


  # --- ACTIONS
  def text_login_token code
    message = "Your Hippocampus code: #{code}"
    msg = TwilioMessenger.new(self.user.phone, Hippocampus::Application.config.phone_number, message)
    msg.send
  end

end
