class AddErrorMessagesToInjectionAttempt < ActiveRecord::Migration
  def change
    add_column :injection_attempts, :error_messages, :json
  end
end
