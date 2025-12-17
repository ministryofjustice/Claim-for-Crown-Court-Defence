require Rails.root.join('db','seeds', 'schemas', 'add_lgfs_fee_scheme_11')

namespace :db do
  namespace :lgfs_scheme_eleven do
    desc 'Display status of db structures and records for LGFS Fee Scheme 11 (CSFR - February 2026)'
    task :status => :environment do
      adder = Seeds::Schemas::AddLGFSFeeScheme11.new(pretend: false)
      puts adder.status
    end
  end
end
