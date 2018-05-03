class AddDeletedAtToInjectionAttempts < ActiveRecord::Migration[4.2]
  def change
    add_column :injection_attempts, :deleted_at, :datetime, default: nil
  end
end
