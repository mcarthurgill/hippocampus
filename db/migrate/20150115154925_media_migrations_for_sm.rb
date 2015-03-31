class MediaMigrationsForSm < ActiveRecord::Migration
  def up
    add_column :sms, :MediaContentTypes, :text
    add_column :sms, :MediaUrls, :text
  end

  def down
  end
end
