class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :AccountSid
      t.string :ToZip
      t.string :FromState
      t.string :Called
      t.string :FromCountry
      t.string :CallerCountry
      t.string :CalledZip
      t.string :Direction
      t.string :FromCity
      t.string :CalledCountry
      t.string :CallerState
      t.string :CallSid
      t.string :CalledState
      t.string :From
      t.string :CallerZip
      t.string :FromZip
      t.ringing :CallStatus
      t.string :ToCity
      t.string :ToState
      t.string :To
      t.string :ToCountry
      t.string :CallerCity
      t.string :ApiVersion
      t.string :Caller
      t.string :CalledCity

      t.timestamps
    end
  end
end
