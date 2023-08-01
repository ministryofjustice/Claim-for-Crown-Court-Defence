require Rails.root.join('db','seeds', 'schemas', 'clean_agfs_offences')

namespace :db do
  namespace :agfs_scheme_offences_clean do
    desc 'Display status of db structures and records for AGFS Offences'
    task :status => :environment do
      cleaner = Seeds::Schemas::CleanAgfsOffences.new(pretend: false)
      cleaner.status
    end

    desc 'Merge AGFS scheme 12 and 13 offences into AGFS scheme 11 offences'
    task :merge, [:not_pretend] => :environment do |_task, args|

      # seed['true'] should seed, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will merge AGFS fee scheme 12 and 13 offences into AGFS fee scheme 11. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow
      
      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      cleaner = Seeds::Schemas::CleanAgfsOffences.new(pretend: pretend)
      cleaner.merge_12
      cleaner.merge_13
      ActiveRecord::Base.logger.level = log_level
    end

    desc 'Revert AGFS offence merge - recreate scheme 12 and 13 offences and update claims'
    task :rollback, [:not_pretend] => :environment do |_task, args|

      # rollback['true'] should rollback, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will recreate spearate offences for AGFS fee scheme 12 and 13. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      cleaner = Seeds::Schemas::CleanAgfsOffences.new(pretend: pretend)
      cleaner.rollback
      ActiveRecord::Base.logger.level = log_level
    end
  end
end
