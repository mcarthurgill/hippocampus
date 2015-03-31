class CreateTwilioMessengers < ActiveRecord::Migration
  def change
    create_table :twilio_messengers do |t|
      t.string :body
      t.string :to_number
      t.string :from_number

      t.timestamps
    end
  end
end
