class AddUniqueCodeToDisbursementTypes < ActiveRecord::Migration
  def change
    add_column :disbursement_types, :unique_code, :string
    add_index :disbursement_types, :unique_code, unique: true
    DisbursementType.connection.schema_cache.clear!
    DisbursementType.reset_column_information
    load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
  end
end
