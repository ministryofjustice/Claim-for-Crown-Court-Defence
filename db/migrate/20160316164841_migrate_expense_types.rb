class MigrateExpenseTypes < ActiveRecord::Migration
  def change
    require File.join(Rails.root, 'db', 'migration_helpers', 'expense_type_migrator')
    MigrationHelpers::ExpenseTypeMigrator.new.run
    puts ">>>>> Expenses have been migrated to the new types.  Expenses by ExpenseType counts:"
    ExpenseType.all.each do |et|
      puts sprintf('%-40s %4d', et.name, et.expenses.count)
    end
  end
end
