class TwilioMessenger < ActiveRecord::Base
  attr_accessible :body, :from_number, :to_number

  def initialize(to_number, from_number, body)
     @to_number = to_number
     @from_number = determine_from_number(to_number)
     @body = body
  end

  def send
    @client = Twilio::REST::Client.new(Hippocampus::Application.config.account_sid, Hippocampus::Application.config.auth_token)
    @account = @client.account

    @message = @account.sms.messages.create({:body => @body, :to => append_plus_to_number(@to_number), :from => append_plus_to_number(@from_number)})
  end

  def append_plus_to_number(number)
    number.first == "+" ? number : number.prepend("+")
  end

  def determine_from_number(number)
    if number.slice(0..1) == '44' || number.slice(0..2) == '+44'
      @from_number = "441526201043"
    else
      @from_number = "16157249333"
    end
    return @from_number
  end

end
