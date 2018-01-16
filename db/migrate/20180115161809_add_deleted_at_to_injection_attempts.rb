class AddDeletedAtToInjectionAttempts < ActiveRecord::Migration
  def change
    add_column :injection_attempts, :deleted_at, :datetime, default: nil
  end
end
