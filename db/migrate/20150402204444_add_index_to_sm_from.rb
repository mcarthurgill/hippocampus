class AddIndexToSmFrom < ActiveRecord::Migration
  def change
    add_index :sms, :From
  end
end
