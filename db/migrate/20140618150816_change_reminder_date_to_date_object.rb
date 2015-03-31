class ChangeReminderDateToDateObject < ActiveRecord::Migration
  def change
    change_column :items, :reminder_date, :date
  end
end
