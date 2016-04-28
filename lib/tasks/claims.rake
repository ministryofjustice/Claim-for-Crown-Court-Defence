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
  task :demo_data, :num_claims_per_state, :num_external_users do |_task, args|
    params = {num_claims_per_state: 1, num_external_users: 1}.merge(args)
    Rake::Task['claims:demo_data:seed'].invoke
    Rake::Task["claims:demo_data:advocates"].invoke(params[:num_claims_per_state], params[:num_external_users])
    Rake::Task['claims:demo_data:litigators'].invoke(params[:num_claims_per_state], params[:num_external_users])
    Rake::Task['claims:demo_data:interims'].invoke(params[:num_claims_per_state], params[:num_external_users])
    Rake::Task['claims:demo_data:transfers'].invoke(params[:num_claims_per_state], params[:num_external_users])
  end

  namespace  :demo_data do
    desc 'ADP Task: Load seed data and demo external users, providers and case workers [num_claims_per_state=1, num_claims_per_user=1]'
    task :seed do
      Rake::Task['db:seed'].invoke
      load File.join(Rails.root, 'lib', 'demo_data', 'demo_seeds.rb')
    end

    desc 'ADP Task: Load demo data Advocate Claims [num_claims_per_state=1, num_claims_per_user=1]'
    task :advocates, :num_claims_per_state, :num_external_users do | _task, args |
      Rake::Task[:environment].invoke
      puts ">>>>>> LOADING DEMO DATA ADVOCATE CLAIMS #{args.inspect}"
      require File.join(Rails.root, 'lib', 'demo_data', 'advocate_claim_generator')
      DemoData::AdvocateClaimGenerator.new(args).run
    end

    desc "ADP Task: Load demo data Litigator Claims [num_claims_per_state=1, num_claims_per_user=1]"
    task :litigators, :num_claims_per_state, :num_external_users do | _task, args |
      Rake::Task[:environment].invoke
      puts ">>>>>> LOADING DEMO DATA LITIGATOR CLAIMS #{args.inspect}"
      require File.join(Rails.root, 'lib', 'demo_data', 'litigator_claim_generator')
      DemoData::LitigatorClaimGenerator.new(num_external_users: 1).run
    end

    desc "ADP Task: Load demo data Interim Claims [num_claims_per_state=1, num_claims_per_user=1]"
    task :interims, :num_claims_per_state, :num_external_users do | _task, args |
      Rake::Task[:environment].invoke
      puts ">>>>>> LOADING DEMO DATA INTERIM  CLAIMS #{args.inspect}"
      require File.join(Rails.root, 'lib', 'demo_data', 'interim_claim_generator')
      DemoData::InterimClaimGenerator.new(num_external_users: 1).run
    end

    desc 'ADP Task: Load demo data Transfer Claims [num_claims_per_state=1, num_claims_per_user=1]'
    task :transfers, :num_claims_per_state, :num_external_users do | _task, args |
      Rake::Task[:environment].invoke
      puts ">>>>>> LOADING DEMO DATA TRANSFERS CLAIMS #{args.inspect}"
      require File.join(Rails.root, 'lib', 'demo_data', 'transfer_claim_generator')
      DemoData::TransferClaimGenerator.new(num_external_users: 1).run
    end
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
