class MigrateExpenseTypes < ActiveRecord::Migration
  def up
    require File.join(Rails.root, 'db', 'migration_helpers', 'expense_type_migrator')
    MigrationHelpers::ExpenseTypeMigrator.new.run
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
