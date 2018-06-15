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
      require Rails.root.join('lib','data_migrator','offence_unique_code_migrator')
      offences = Offence.joins(:offence_class).where.not(offence_class: nil).unscope(:order).order('offences.description COLLATE "C", offence_classes.class_letter COLLATE "C"')
      migrator = DataMigrator::OffenceUniqueCodeMigrator.new(relation: offences)
      migrator.migrate!
    end

    desc 'Migrate offence data for scheme 10 offences to have unique code based on description and offence category/band'
    task :offence_unique_code_scheme_10 => :environment do
      require Rails.root.join('lib','data_migrator','offence_unique_code_migrator')
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

    desc 'Modify offence data for scheme 10 offences and regenerate their unique codes'
    task :modify_scheme_10_offences => :environment do
      require Rails.root.join('db','seed_helper')
      def relation
        @relation ||= Offence.where(offence_class: nil)
      end

      relation.
        where(description: 'Causing a person to engage in sexual activity without consent: Sexual Offences Act 2003, s.4(4)').
        update_all(description: 'Causing a person to engage in sexual activity without consent')

      relation.
        where('description ILIKE ?', 'Demanding payment for the inclusion of a person%').
        update_all(description: 'Directory entries')

      relation.
        where(description: 'Failure to comply with a remedial order.').
        update_all(description: 'Failing to comply with a remedial order')

      relation.
        where(description: 'Give to another person disclosed protected material in connection with sexual offence proceedings.').
        update_all(description: 'Give that (protected) material or any copy of it, or otherwise reveal its contents, to any other person')

      relation.
        where(description: 'Offences arising from breach of regulation 20 (Monies in Trust) and 21 (Monies in Trust where other party to contract is acting otherwise than in the court of business).').
        update_all(description: 'Offences arising from breach of Regulations 20 and 21')

      relation.
        where(description: 'Offences under regulations 6 (Borrowing and banking of landfill allowances) and 7 (Trading and other transfer of landfill allowances).').
        update_all(description: 'Offences under regulations under s.6 and s.7')

      relation.
        where(description: 'Possession or supply of apparatus for use in dishonestly obtaining an electronic communication service.').
        update_all(description: 'Possession or supply of apparatus etc for contravening s.125')

      SeedHelper.find_or_create_scheme_10_offence!(
        description: "Rape",
        offence_band: OffenceBand.find_by(description: '4.1'),
        contrary: "Sexual Offences Act 1956, s.1",
        year_chapter: "1956 c. 69"
      )

      SeedHelper.find_or_create_scheme_10_offence!(
        description: "Rape",
        offence_band: OffenceBand.find_by(description: '5.1'),
        contrary: "Sexual Offences Act 1956, s.1",
        year_chapter: "1956 c. 69"
      )

      Rake::Task['data:migrate:offence_unique_code_scheme_10'].invoke
    end

    namespace :providers do
      desc 'Seed LGFS supplier data (prefix with SEEDS_DRY_MODE=false to disable DRY mode)'
      task lgfs_suppliers: :environment do
        require "#{Rails.root}/lib/data_migrator/provider_suppliers_migrator"
        options = {}
        options[:dry_run] = ENV['SEEDS_DRY_MODE'].present? ? ENV['SEEDS_DRY_MODE'] : 'true'
        options[:seed_file] = ENV['SEED_FILE_PATH'] if ENV['SEED_FILE_PATH'].present?
        DataMigrator::ProviderSuppliersMigrator.call(options)
      end
    end
  end
end
