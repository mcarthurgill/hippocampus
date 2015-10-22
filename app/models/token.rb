class Token < ActiveRecord::Base

  # --- ATTRIBUTES
  attr_accessible :token_string, :user_id, :addon_id, :status, :object_type

  # --- ASSOCIATIONS
  belongs_to :user
  belongs_to :addon

  # --- SCOPES
  scope :recent, ->{ where('created_at > ?', 5.minutes.ago) }
  scope :live, ->{ where('status = ?', "live") }
  scope :match, ->(token_string, user_id, addon_id) { where({:token_string => token_string, :user_id => user_id, :addon_id => addon_id}) }
  scope :for_user_and_addon, ->(user_id, addon_id) { where("user_id = ? AND addon_id = ?", user_id, addon_id) }
  scope :for_addon, ->(addon_id) { where("addon_id = ? AND user_id IS NULL", addon_id) }

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
    OutgoingMessage.send_text_to_number_with_message_and_reason(self.user.phone, message, "token")
  end

  def update_status(new_status)
    self.status = new_status 
    self.save
  end


  # --- HELPERS
  def live?
    self.status == "live"
  end
end
