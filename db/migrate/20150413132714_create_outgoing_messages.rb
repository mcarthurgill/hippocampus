class CreateOutgoingMessages < ActiveRecord::Migration
  def change
    create_table :outgoing_messages do |t|
      t.string :to_number
      t.string :from_number
      t.string :message
      t.string :reason

      t.timestamps
    end
  end
end
