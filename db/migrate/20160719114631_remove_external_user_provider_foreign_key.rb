class RemoveExternalUserProviderForeignKey < ActiveRecord::Migration

  # Having problems sometimes to find the FK with error: Table 'external_users' has no foreign key on column 'provider_id'
  # This will work around
  #
  def up
    remove_foreign_key :external_users, :providers
  rescue
    add_foreign_key :external_users, :providers
    remove_foreign_key :external_users, :providers
  end

  def down
    add_foreign_key :external_users, :providers
  end
end
