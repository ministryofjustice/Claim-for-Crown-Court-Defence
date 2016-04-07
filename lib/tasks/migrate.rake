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



    desc 'Adds Graduated Fee types to fee_types_table'
    task :grad_fee_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'fee_types.rb')
    end


    desc 'Updates case types to point tothe correct graduated fee type'
    task :case_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'case_types.rb')
    end

    desc 'Seed Disbursement Types'
    task :disbursement_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
    end

    desc 'Seed New Warrant Fee Type'
    task :warrant_fee_type => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'fee_types.rb')
    end


    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
          :expenses => 'Expense types and expenses',
          :certification => 'Certifications',
          :grad_fee_types => 'Graduated Fee Types',
          :case_types => 'New Case Types',
          :disbursement_types => 'Disbursement types',
          :warrant_fee_type => 'Warrant fee type'
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end
 
