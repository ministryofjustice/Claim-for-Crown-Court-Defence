namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./public/assets/dev/images/')
    FileUtils.rm_rf('./public/assets/test/images/')
  end

  
  desc 'Loads dummy claims'
  task :demo_data => 'db:seed' do
    require File.dirname(__FILE__) + '/../demo_data/claim_generator'
    DemoData::ClaimGenerator.new.run
    Rake::Task['db:data:dump'].invoke
  end


  desc 'archives or deletes stale claims'
  task :archive_stale => :environment do
    TimedTransition::BatchTransitioner.new.run
  end
end

