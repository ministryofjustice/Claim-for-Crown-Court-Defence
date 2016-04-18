 namespace :data do
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

    desc 'Seed new fee types'
    task :fee_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'fee_types.rb')
    end

    desc 'Updates case types to point to the correct graduated and fixed fee types'
    task :case_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'case_types.rb')
    end

    desc 'Seed Disbursement Types'
    task :disbursement_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
    end

    desc 'Seed Supplier Numbers'
    task :supplier_numbers => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'supplier_numbers.rb')
    end

    desc 'Remove warrant and transfer case types'
    task :remove_warrant_transfer => :environment do
      CaseType.find_by(name: 'Warrant claim').destroy
      CaseType.find_by(name: 'Transfer').destroy
    end

    desc 'Add interim role to case types'
    task :add_interim_role_to_case_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'case_types.rb')
    end

    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        supplier_numbers: 'Seeding supplier numbers to litigator providers'
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end

