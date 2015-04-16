class ChangeOutgoingMessageToText < ActiveRecord::Migration
  def change
    change_column :outgoing_messages, :message, :text
  end
end
