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
    Rake::Task['claims:dump'].invoke
  end

  desc 'dumps database to yaml files'
  task :dump => :environment do
    data_dir = "#{Rails.root}/db/data"
    result = FileUtils.rmtree data_dir if File.exist?(data_dir)
    ENV['dir'] = 'data'                     # always relative to the data directory
    Rake::Task['db:data:dump_dir'].invoke
  end


  desc 'restores database from yaml files'
  task :restore => :environment do
    ENV['dir'] = 'data'                     # always relative to the data directory
    Rake::Task['db:data:load_dir'].invoke
  end

  desc 'archives or deletes stale claims'
  task :archive_stale => :environment do
    TimedTransition::BatchTransitioner.new.run
  end
end



