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

    desc 'Seed Disbursement Types'
    task :disbursement_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
    end

    desc 'Seed Supplier Numbers'
    task :supplier_numbers => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'supplier_numbers.rb')
    end

    desc 'Reseed fee types'
    task :reseed_fee_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'fee_types.rb')
    end

    desc 'Reseed expense types'
    task :reseed_expense_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'expense_types.rb')
    end

    desc 'Reseed offences'
    task :reseed_offences => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'offences.rb')
    end

    desc 'Set fee types quantities to decimal for SPF, WPF, RNF, CAV, WOA'
    task :set_quantity_is_decimal => :environment do
      %w{ SPF WPF RNF RNL CAV WOA }.each do |code|
        recs = Fee::BaseFeeType.where(code: code).where.not(quantity_is_decimal: true)
        recs.each do |rec| rec.update(quantity_is_decimal: true)
          puts "Quantity is decimal set to TRUE for fee type #{code}"
        end
      end
    end

    desc 'Rename dishonesty offences'
    task :rename_dishonesty_offences => :environment do
      Offence.where(description: 'Obtaining services dishonestly').update_all(description: 'Obtaining services by dishonesty')
    end

    desc 'Remove contempt AGFS fixed fee types'
    task :remove_contempt_fee_types => :environment do
      old_ids = Fee::FixedFeeType.where(code: %w(CON COA)).pluck(:id)
      new_id  = Fee::FixedFeeType.by_code('ZCON').id
      Fee::FixedFee.where(fee_type_id: old_ids).update_all(fee_type_id: new_id)
      Fee::FixedFeeType.delete_all(id: old_ids)
    end

    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        'reseed_expense_types' => 'Reseed the expense types as there are some new.',
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end

