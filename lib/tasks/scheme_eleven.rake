namespace :db do
  namespace :scheme_eleven do

    desc 'Create the db structures and records required for AGFS10'
    task :seed => :environment do
      abort 'Scheme eleven has already been seeded' if Offence.count > 1800
      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1

      pre_run = { fee_scheme: FeeScheme.count, offence_categories: OffenceCategory.count, offence_bands: OffenceBand.count }
      seed_file = "#{Rails.root}/db/seeds/scheme_11.rb"
      puts "Running scheme eleven seed file: #{seed_file}"
      load seed_file
      puts 'Import complete'
      puts "FeeSchemes is now: #{FeeScheme.count}, it should be changed from #{pre_run[:fee_scheme]}"
      puts "OffenceCategories is now: #{OffenceCategory.count}, it should be unchanged from #{pre_run[:offence_categories]}"
      puts "OffenceBands is now: #{OffenceBand.count}, it should be unchanged from #{pre_run[:offence_bands]}"
      puts "Expect Offences to equal 1248: #{Offence.where(id: 3000..Float::INFINITY).count}"
      ActiveRecord::Base.logger.level = log_level
    end

    task :rollback => :environment do
      puts 'Removed scheme 11 offence_fee_schemes' if OffenceFeeScheme.where(offence_id: 3000..4500, fee_scheme_id: 4).destroy_all
      puts 'Removed scheme 11 offences' if Offence.where(id: 3000..4500).destroy_all
      scheme_11 = FeeScheme.find_by(name: 'AGFS', version: 11)
      puts 'Deleted fee scheme 11' if scheme_11&.delete
      scheme_10 = FeeScheme.find_by(name: 'AGFS', version: 10)
      puts 'Ensured the scheme 10 end date is nil' if scheme_10&.update(end_date: nil)
    end
  end
end
