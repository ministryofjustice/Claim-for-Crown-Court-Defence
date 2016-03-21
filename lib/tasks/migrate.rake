namespace :migrate do
  
  desc 'migrate expenses from old expense types to new' 
  task :expenses => :environment do
    require File.join Rails.root, 'db', 'migration_helpers', 'new_expense_type_adder'
    require File.join Rails.root, 'db', 'migration_helpers', 'expense_type_migrator'
    require File.join Rails.root, 'db', 'migration_helpers', 'old_expense_type_remover'
    MigrationHelpers::NewExpenseTypeAdder.new.run
    MigrationHelpers::ExpenseTypeMigrator.new.run
    MigrationHelpers::OldExpenseTypeRemover.new.run

    puts '############################################################################################'
    puts '#                                                                                          #'
    puts '# Expense migration complete.  Now change the Settings.expense_schema_version to 2 to      #'
    puts '# ensure that all new expense records get written as version 2 and are correctly validated #'
    puts '#                                                                                          #'
    puts '############################################################################################'
  end


  desc 'Correct capitalization on Certification Types' 
  task :certifications => :environment do
    load File.join(Rails.root, 'db', 'seeds', 'certification_types.rb')
  end
end
 
