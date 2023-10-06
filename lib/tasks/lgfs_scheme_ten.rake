require Rails.root.join('db','seeds', 'schemas', 'add_lgfs_fee_scheme_10')

namespace :db do
  namespace :lgfs_scheme_ten do
    desc 'Display status of db structures and records for LGFS Fee Scheme 10 (CLAIR - September 2022)'
    task :status => :environment do
      adder = Seeds::Schemas::AddLgfsFeeScheme10.new(pretend: false)
      puts adder.status
    end

    desc 'Create the db structures and records required for LGFS Fee Scheme 10 (CLAIR - September 2022), pass \'true\' to run'
    task :seed, [:not_pretend] => :environment do |_task, args|

      # seed['true'] should seed, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will seed data for LGFS Fee Scheme 10 (CLAIR - September 2022). Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      adder = Seeds::Schemas::AddLgfsFeeScheme10.new(pretend: pretend)
      adder.up
      ActiveRecord::Base.logger.level = log_level
    end

    desc 'Destroy the db structures and records required for LGFS Fee Scheme 10 (CLAIR - September 2022), pass \'true\' to run'
    task :rollback, [:not_pretend] => :environment do |_task, args|

      # rollback['true'] should rollback, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will destroy LGFS Fee Scheme 10 (CLAIR - September 2022), offences and fee types. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      adder = Seeds::Schemas::AddLgfsFeeScheme10.new(pretend: pretend)
      adder.down
    end
  end
end
