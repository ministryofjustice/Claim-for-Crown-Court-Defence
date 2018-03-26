namespace :db do
  namespace :seed do

    desc 'Create the db structures and records required for AGFS10'
    task :scheme_ten => :environment do
      abort 'Scheme ten has already been seeded' if Offence.count > 500
      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1

      seed_file = "#{Rails.root}/db/seeds/scheme_ten.rb"
      puts "Running scheme ten seed file: #{seed_file}"
      load seed_file
      puts 'Import complete'
      puts "Expect FeeSchemes to equal 3: #{FeeScheme.count}"
      puts "Expect OffenceCategories to equal 17: #{OffenceCategory.count}"
      puts "Expect OffenceBands to equal 48: #{OffenceBand.count}"
      puts "Expect Offences to equal 1244: #{Offence.where(id: 1000..Float::INFINITY).count}"
      ActiveRecord::Base.logger.level = log_level
    end
  end
end
