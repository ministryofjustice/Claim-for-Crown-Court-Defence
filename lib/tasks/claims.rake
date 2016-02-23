namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./public/assets/dev/images/')
    FileUtils.rm_rf('./public/assets/test/images/')
  end

  desc 'Creates sample users'
  task :sample_users => :environment do
    load File.join(Rails.root, 'lib', 'demo_data', 'demo_seeds.rb')
  end

  desc 'Loads dummy claims'
  task :demo_data => 'db:seed' do
    load File.join(Rails.root, 'lib', 'demo_data', 'demo_seeds.rb')
    require File.dirname(__FILE__) + '/../demo_data/claim_generator'
    DemoData::ClaimGenerator.new.run
  end

  desc 'archives or deletes stale claims'
  task :archive_stale => :environment do
    TimedTransition::BatchTransitioner.new.run
  end
end

