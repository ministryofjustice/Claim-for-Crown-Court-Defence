namespace :claims do
  desc 'Check all current claims case numbers against the regex'
  task :check_export, [:start_id] => :environment do |_task, args|
    total = 0
    current_id = 0
    start_id = args[:start_id] || 1
    Claim::BaseClaim.active.where(Claim::BaseClaim.arel_table[:id].gteq(start_id)).where.not(state: %w(draft archived_pending_delete)).order(id: :asc).find_each(batch_size: 100) do |claim|
      total += 1
      current_id = claim.id
      message = Messaging::ExportRequest.new(claim)
      unless message.valid?
        puts "[FAIL] Claim ID #{claim.id.to_s.ljust(5, ' ')} #{claim.state}"
        puts message.errors
        puts
        puts message.__send__(:request_message)
        break
      end
    end
    puts
    puts "Total claims processed: #{total}. Last claim ID processed: #{current_id}"
    puts "You can continue from here with: rake claims:check_export[#{current_id}]"
  end

  # TODO: this is just for the PoC. Eventually there will be a scheduled task.
  desc 'Request exported claims status from CCR'
  task :status_updater => :environment do
    puts 'Running...'
    Messaging::Status::StatusUpdater.new.run
    puts 'Done.'
  end

  desc 'Check all current claims case numbers against the regex'
  task :check_case_numbers => :environment do
    Claim::BaseClaim.active.where.not(case_number: nil, state: %w(draft archived_pending_delete)).order(id: :asc).pluck(:id, :case_number).each do |claim_id, case_number|
      unless !!case_number.match(BaseValidator::CASE_NUMBER_PATTERN)
        claim = Claim::BaseClaim.find(claim_id)
        puts "ERROR: #{case_number} -- claim ID #{claim.id} -- #{claim.external_user.email} -- #{claim.state}"
      end
    end
  end

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./public/assets/dev/images/')
    FileUtils.rm_rf('./public/assets/test/images/')
  end

  desc 'Creates sample users'
  task :sample_users => :environment do
    require File.join(Rails.root, 'lib', 'demo_data', 'external_user_seeder')
    require File.join(Rails.root, 'lib', 'demo_data', 'case_worker_seeder')
    print 'Seeding sample users...'
    DemoData::ExternalUserSeeder.run
    DemoData::CaseWorkerSeeder.run
    puts 'done'.green
  end

  desc 'Loads dummy claims'
  task :demo_data, :num_claims_per_state, :num_external_users do |_task, args|
    params = {num_claims_per_state: 1, num_external_users: 1}.merge(args)
    Rake::Task['claims:sample_users'].invoke
    Rake::Task["claims:demo_data:advocates"].invoke(params[:num_claims_per_state], params[:num_external_users])
    # Rake::Task["claims:demo_data:advocate_interims"].invoke(params[:num_claims_per_state], params[:num_external_users]) # TODO
    Rake::Task['claims:demo_data:litigators'].invoke(params[:num_claims_per_state], params[:num_external_users])
    Rake::Task['claims:demo_data:interims'].invoke(params[:num_claims_per_state], params[:num_external_users])
    Rake::Task['claims:demo_data:transfers'].invoke(params[:num_claims_per_state], params[:num_external_users])
  end

  namespace :demo_data do
    desc 'CCCD Task: Load demo data Advocate Claims [num_claims_per_state=1, num_claims_per_user=1]'
    task :advocates, :num_claims_per_state, :num_external_users do |task, args|
      Rake::Task[:environment].invoke
      puts "#{task.name} with #{args}".green
      require 'fileutils'
      doc_store = File.join(Rails.root, 'public', 'assets', 'dev', 'images', 'docs')
      FileUtils.rm_r(doc_store, secure: true) if Dir.exist?(doc_store)
      require File.join(Rails.root, 'lib', 'demo_data', 'advocate_claim_generator')
      DemoData::AdvocateClaimGenerator.new(args).run
    end

    desc "Load demo data Litigator Claims [num_claims_per_state=1, num_claims_per_user=1]"
    task :litigators, :num_claims_per_state, :num_external_users do |task, args|
      Rake::Task[:environment].invoke
      puts "#{task.name} with #{args}".green
      DemoData::ClaimGenerator::LGFS::Litigator.new(num_external_users: 1).run
    end

    desc "Load demo data Interim Claims [num_claims_per_state=1, num_claims_per_user=1]"
    task :interims, :num_claims_per_state, :num_external_users do |task, args|
      Rake::Task[:environment].invoke
      puts "#{task.name} with #{args}".green
      DemoData::ClaimGenerator::LGFS::Interim.new(num_external_users: 1).run
    end

    desc 'Load demo data Transfer Claims [num_claims_per_state=1, num_claims_per_user=1]'
    task :transfers, :num_claims_per_state, :num_external_users do |task, args|
      Rake::Task[:environment].invoke
      puts "#{task.name} with #{args}".green
      DemoData::ClaimGenerator::LGFS::Transfer.new(num_external_users: 1).run
    end
  end

  desc 'Delete sample providers'
  task :destroy_sample_providers => :environment do
    require File.join(Rails.root, 'lib', 'demo_data', 'claim_destroyer')
    DemoData::ClaimDestroyer.new.run
  end

  desc 'Archives or deletes stale claims'
  task :archive_stale, [:param] => :environment do |_task, args|
    if args.names.size != 1
      raise ArgumentError.new "Only valid parameter is 'dummy'"
    end

    case args[:param]
    when 'dummy'
      @dummy = true
    when nil
      @dummy = false
    else
      raise ArgumentError.new "Only valid parameter is 'dummy'"
    end

    slack_notifier = SlackNotifier.new(
      'laa-cccd-alerts',
      formatter: SlackNotifier::Formatter::Transitioner.new,
      slack_bot_name: 'Stale Claim Archiver'
    )

    TimedTransitions::BatchTransitioner.new(limit: 10000, dummy: @dummy, notifier: slack_notifier).run
  end

  desc 'Create a CSV file of all archived claims'
  task :archive_report, [:filename] => :environment do |_task, args|
    require_relative 'rake_helpers/archived_claims'

    puts "Writing archived claims to #{args[:filename]}".green
    RakeHelpers::ArchivedClaims.write args[:filename]
    puts 'Done'.green
  end
end
