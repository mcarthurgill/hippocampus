class AddRecordingUrlToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :RecordingUrl, :string
  end
end
