namespace :data do
  namespace :migrate do

    ########################################################################################################################
    ###########                                                                                               ##############
    ###########  DO NOT DELETE THIS TASK - IS NEEDED FOR THE BUILD UNTIL SUCH TIME AS THE BUILD IS CHANGED TO ##############
    ###########  USE THE DB SCHEMA RATHER THAN RUNNING ALL THE MIGRATIONS                                     ##############
    ###########                                                                                               ##############
    ########################################################################################################################
    desc 'Set fee types quantities to decimal for SPF, WPF, RNF, CAV, WOA'
    task :set_quantity_is_decimal => :environment do
      %w{ SPF WPF RNF RNL CAV WOA }.each do |code|
        recs = Fee::BaseFeeType.where(code: code).where.not(quantity_is_decimal: true)
        recs.each do |rec| rec.update(quantity_is_decimal: true)
        puts "Quantity is decimal set to TRUE for fee type #{code}"
        end
      end
    end

    desc 'update vat amounts'
    task :vat => :environment do
      Claim::BaseClaim.connection.execute('UPDATE disbursements SET vat_amount = 0.0 WHERE vat_amount IS NULL')
      Claim::BaseClaim.connection.execute('UPDATE expenses SET vat_amount = 0.0 WHERE vat_amount IS NULL')
      claim_ids = Claim::BaseClaim.pluck(:id)
      num_claims = claim_ids.size
      claim_ids.each_with_index do |claim_id, i|
        begin
          puts "Updated #{i} claims of #{num_claims}" if i % 1000 == 0
          claim = Claim::BaseClaim.find(claim_id)
          claim.update_disbursements_total
          claim.update_expenses_total
          claim.update_fees_total
          claim.save!
        rescue => err
          puts ">>>> ERROR saving #{claim_id} >>>>> #{err.class} :: #{err.message} "
        end
      end
    end

    desc 'Update the value band ids'
    task :value_bands => :environment do
      i = 0
      Claim::BaseClaim.find_each do |claim|
        i += 1
        vbid = Claims::ValueBands.band_id_for_claim(claim)
        if claim.value_band_id != vbid
          puts ">>>>>>>>>>>>>> updating claim #{claim.id} to value band #{vbid} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
          claim.update_columns(value_band_id: vbid)
        end
      end
      puts "#{i} claims examined"
    end

    desc 'Reseed expense types'
    task :reseed_expense_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'expense_types.rb')
    end

    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        'reseed_expense_types' => 'Reseed the expense types as there are some new.'
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end

    desc 'Migrate offence data for scheme 9 to have unique code based on description and class letter'
    task :offence_unique_code_scheme_9 => :environment do
      require Rails.root.join('lib','data_migrator','offence_unique_code_migrator').to_s
      offences = Offence.joins(:offence_class).where.not(offence_class: nil).unscope(:order).order('offences.description COLLATE "C", offence_classes.class_letter COLLATE "C"')
      migrator = DataMigrator::OffenceUniqueCodeMigrator.new(relation: offences)
      migrator.migrate!
    end

    desc 'Migrate offence data for scheme 10 offences to have unique code based on description and offence category/band'
    task :offence_unique_code_scheme_10 => :environment do
      require Rails.root.join('lib','data_migrator','offence_unique_code_migrator').to_s
      offences = Offence.joins(:offence_band).where(offence_class: nil).unscope(:order).order('offences.description COLLATE "C", offences.contrary COLLATE "C", offence_bands.description COLLATE "C"')
      migrator = DataMigrator::OffenceUniqueCodeMigrator.new(relation: offences)
      migrator.migrate!
    end

    desc 'Migrate injection attempts error_message:string to error_messages:json'
    task :injection_errors => :environment do
      require Rails.root.join('lib','data_migrator','injection_error_migrator').to_s
      migrator = DataMigrator::InjectionErrorMigrator.new
      migrator.migrate!
    end
  end
end

