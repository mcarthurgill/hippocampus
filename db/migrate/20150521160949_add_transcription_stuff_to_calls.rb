class AddTranscriptionStuffToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :TranscriptionSid, :string
    add_column :calls, :TranscriptionText, :string
    add_column :calls, :TranscriptionStatus, :string
    add_column :calls, :TranscriptionUrl, :string

    add_column :calls, :item_id, :integer
  end
end
