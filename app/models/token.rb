class Token < ActiveRecord::Base

  # --- ATTRIBUTES
  attr_accessible :token_string, :user_id

  # --- ASSOCIATIONS
  belongs_to :user

  # --- SCOPES
  scope :live, ->{ where('created_at > ?', 5.minutes.ago) }
  scope :match, ->(token_string, user_id) { where('token_string = ? AND user_id = ?', token_string, user_id) }


  # --- CREATION
  def self.with_params params
    token = Token.new(params)
    return token
  end

  def assign_token
    string = "#{Random.new.rand(1111...9999)}"
    self.token_string = string[0..3]
    return string
  end


  # --- ACTIONS
  def send_token code
    message = "Your Hippocampus code: #{code}"
    msg = TwilioMessenger.new(self.user.phone, Hippocampus::Application.config.phone_number, message)
    msg.send
  end

end
