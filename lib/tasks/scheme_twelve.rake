require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_12')

namespace :db do
  namespace :scheme_twelve do
    desc 'Display status of db structures and records for AGFS fee scheme 12'
    task :status => :environment do
      adder = Seeds::Schemas::AddAgfsFeeScheme12.new(pretend: false)
      puts adder.status
    end

    desc 'Create the db structures and records required for AGFS fee scheme 12'
    task :seed => :environment do
      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1

      adder = Seeds::Schemas::AddAgfsFeeScheme12.new(pretend: false)
      adder.up
      ActiveRecord::Base.logger.level = log_level
    end

    desc 'Destroy the db structures and records required for AGFS fee scheme 12'
    task :rollback => :environment do
      adder = Seeds::Schemas::AddAgfsFeeScheme12.new(pretend: false)
      adder.down
    end
  end
end
