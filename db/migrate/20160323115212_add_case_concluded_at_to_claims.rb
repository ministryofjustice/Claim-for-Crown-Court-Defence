class AddCaseConcludedAtToClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :case_concluded_at, :date
  end
end
