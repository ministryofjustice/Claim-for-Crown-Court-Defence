class RemoveErrorMessageFromInjectionAttempts < ActiveRecord::Migration
  def change
    remove_column :injection_attempts, :error_message, :string
  end
end
