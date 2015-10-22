class AddTranscriptionTextToMedia < ActiveRecord::Migration
  def change
    add_column :media, :transcription_text, :text
  end
end
