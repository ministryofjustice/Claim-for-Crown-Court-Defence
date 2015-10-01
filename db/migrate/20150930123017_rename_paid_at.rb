class RenamePaidAt < ActiveRecord::Migration
  def change
    rename_column :claims , :paid_at, :authorised_at
  end
end
