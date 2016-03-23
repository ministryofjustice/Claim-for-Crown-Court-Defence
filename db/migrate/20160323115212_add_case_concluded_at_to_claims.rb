class AddCaseConcludedAtToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :case_concluded_at, :date
  end
end
