class AddCreationReasonToBucket < ActiveRecord::Migration
  def change
    add_column :buckets, :creation_reason, :integer
  end
end
