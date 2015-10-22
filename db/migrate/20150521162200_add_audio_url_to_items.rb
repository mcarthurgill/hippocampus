class AddAudioUrlToItems < ActiveRecord::Migration
  def change
    add_column :items, :audio_url, :string
  end
end
