class RenamePaidAt < ActiveRecord::Migration[4.2]
  def change
    rename_column :claims , :paid_at, :authorised_at
  end
end
