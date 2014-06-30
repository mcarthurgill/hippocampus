class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|
      t.string :ToCountry
      t.string :ToState
      t.string :SmsMessageSid
      t.string :NumMedia
      t.string :ToCity
      t.string :FromZip
      t.string :SmsSid
      t.string :FromState
      t.string :SmsStatus
      t.string :FromCity
      t.text :Body
      t.string :FromCountry
      t.string :To
      t.string :ToZip
      t.string :MessageSid
      t.string :AccountSid
      t.string :From
      t.string :ApiVersion

      t.timestamps
    end
  end
end
