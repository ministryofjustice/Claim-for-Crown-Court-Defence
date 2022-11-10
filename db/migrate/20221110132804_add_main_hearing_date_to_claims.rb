class AddMainHearingDateToClaims < ActiveRecord::Migration[6.1]
  def change
    add_column :claims, :main_hearing_date, :date
  end
end
