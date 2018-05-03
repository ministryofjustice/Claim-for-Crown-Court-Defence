class RemoveErrorMessageFromInjectionAttempts < ActiveRecord::Migration[4.2]
  def change
    remove_column :injection_attempts, :error_message, :string
  end
end
