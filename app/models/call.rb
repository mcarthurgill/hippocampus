class Call < ActiveRecord::Base
  attr_accessible :AccountSid, :ApiVersion, :CallSid, :CallStatus, :Called, :CalledCity, :CalledCountry, :CalledState, :CalledZip, :Caller, :CallerCity, :CallerCountry, :CallerState, :CallerZip, :Direction, :From, :FromCity, :FromCountry, :FromState, :FromZip, :To, :ToCity, :ToCountry, :ToState, :ToZip
end
