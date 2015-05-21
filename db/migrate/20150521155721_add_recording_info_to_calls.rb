class AddRecordingInfoToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :Digits, :string
    add_column :calls, :RecordingDuration, :string
    add_column :calls, :RecordingSid, :string
  end
end
