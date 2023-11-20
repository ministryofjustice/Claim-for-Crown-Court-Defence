require Rails.root.join('db','seeds', 'schemas', 'clean_lgfs_fee_scheme_10')

namespace :db do
  namespace :lgfs_scheme_ten_clean do
    desc 'Display status of db structures and records for LGFS Fee Scheme 10 (CLAIR - September 2022)'
    task :status => :environment do
      cleaner = Seeds::Schemas::CleanLGFSFeeScheme10.new(pretend: false)
      cleaner.status
    end

    desc 'Merge LGFS scheme 10 offences into LGFS scheme 9 offences'
    task :merge, [:not_pretend] => :environment do |_task, args|

      # seed['true'] should seed, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will merge LGFS fee scheme 10 offences into LGFS fee scheme 9. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      cleaner = Seeds::Schemas::CleanLGFSFeeScheme10.new(pretend: pretend)
      cleaner.up
      ActiveRecord::Base.logger.level = log_level
    end


    desc 'Revert LGFS fee scheme 10 offences'
    task :rollback, [:not_pretend] => :environment do |_task, args|

      # rollback['true'] should rollback, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will recreate spearate offences for LGFS fee scheme 10. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      cleaner = Seeds::Schemas::CleanLGFSFeeScheme10.new(pretend: pretend)
      cleaner.down
      ActiveRecord::Base.logger.level = log_level
    end
  end
end
