class AddMediaUrlToOutgoingMessage < ActiveRecord::Migration
  def change
    add_column :outgoing_messages, :media_url, :string
  end
end
