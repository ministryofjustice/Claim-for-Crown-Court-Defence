require Rails.root.join('db', 'seeds', 'schemas', 'add_agfs_fee_scheme_18')

namespace :db do
  namespace :agfs_scheme_eighteen do
    desc 'Display the status of AGFS Fee Scheme 18'
    task status: :environment do
      puts Seeds::Schemas::AddAGFSFeeScheme18.new.status
    end

    desc 'Seed AGFS Fee Scheme 18; pass true to apply, otherwise preview'
    task :seed, [:not_pretend] => :environment do |_task, args|
      pretend = args.fetch(:not_pretend, 'false').to_s.downcase != 'true'
      continue?('This will seed AGFS Fee Scheme 18. Type yes to apply.') unless pretend
      puts Rainbow("#{pretend ? 'pretending' : 'working'}...").yellow
      puts Seeds::Schemas::AddAGFSFeeScheme18.new(pretend: pretend).up
    end

    desc 'Roll back AGFS Fee Scheme 18; pass true to apply, otherwise preview'
    task :rollback, [:not_pretend] => :environment do |_task, args|
      pretend = args.fetch(:not_pretend, 'false').to_s.downcase != 'true'
      continue?('This will roll back AGFS Fee Scheme 18. Type yes to apply.') unless pretend
      puts Rainbow("#{pretend ? 'pretending' : 'working'}...").yellow
      puts Seeds::Schemas::AddAGFSFeeScheme18.new(pretend: pretend).down
    end
  end
end
