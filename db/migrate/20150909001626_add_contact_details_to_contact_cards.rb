class AddContactDetailsToContactCards < ActiveRecord::Migration
  def change
    add_column :contact_cards, :contact_details, :text
  end
end
