require Rails.root.join('db','seeds', 'schemas', 'add_agfs_fee_scheme_12')
require_relative 'rake_helpers/rake_utils'
include RakeUtils

namespace :db do
  namespace :scheme_twelve do
    desc 'Display status of db structures and records for AGFS fee scheme 12'
    task :status => :environment do
      adder = Seeds::Schemas::AddAGFSFeeScheme12.new(pretend: false)
      puts adder.status
    end

    desc 'Create the db structures and records required for AGFS fee scheme 12, pass \'true\' to run'
    task :seed, [:not_pretend] => :environment do |_task, args|

      # seed['true'] should seed, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will seed CLAR. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      adder = Seeds::Schemas::AddAGFSFeeScheme12.new(pretend: pretend)
      adder.up
      ActiveRecord::Base.logger.level = log_level
    end

    desc 'Destroy the db structures and records required for AGFS fee scheme 12, pass \'true\' to run'
    task :rollback, [:not_pretend] => :environment do |_task, args|

      # rollback['true'] should rollback, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will destroy CLAR scheme, offences and fee types. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      adder = Seeds::Schemas::AddAGFSFeeScheme12.new(pretend: pretend)
      adder.down
    end
  end
end
