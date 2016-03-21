namespace :claims do

  desc "ADP Task: Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./public/assets/dev/images/')
    FileUtils.rm_rf('./public/assets/test/images/')
  end

  desc 'Creates sample users'
  task :sample_users => :environment do
    load File.join(Rails.root, 'lib', 'demo_data', 'demo_seeds.rb')
  end

  desc 'ADP Task: Loads dummy claims'
  task :demo_data => 'db:seed' do
    load File.join(Rails.root, 'lib', 'demo_data', 'demo_seeds.rb')
    require File.join(Rails.root, 'lib', 'demo_data', 'advocate_claim_generator')
    require File.join(Rails.root, 'lib', 'demo_data', 'litigator_claim_generator')
    DemoData::AdvocateClaimGenerator.new(num_external_users: 2).run
    DemoData::LitigatorClaimGenerator.new(num_external_users: 2).run
  end

  desc  'ADP Task: Delete sample providers'
  task :destroy_sample_providers => :environment do
    require File.join(Rails.root, 'lib', 'demo_data', 'claim_destroyer')
    DemoData::ClaimDestroyer.new.run
  end

  desc 'ADP Task: Archives or deletes stale claims'
  task :archive_stale => :environment do
    TimedTransition::BatchTransitioner.new.run
  end
end
