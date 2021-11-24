namespace :canary do
  desc 'Create a new Canary factory auth token'
  task :create_factory_auth, [:memo, :flock_id] => :environment do |_task, args|
    abort 'Memo required' if args[:memo].nil?

    require_relative 'rake_helpers/canary_configuration'

    factory = ThinkstCanary::FactoryGenerator.new.create_factory(
      flock_id: args[:flock_id] || ENV['CANARY_FLOCK_ID'],
      memo: args[:memo]
    )
    puts "# New factory auth token (created #{Time.zone.now})"
    puts "# Memo: #{factory.memo}"
    puts "# Flock id: #{factory.flock_id}"
    puts "CANARY_FACTORY_AUTH_TOKEN=#{factory.factory_auth}"
  end

  desc 'Delete a Canary factory auth token'
  task :delete_factory_auth, [:auth_token] => :environment do |_task, args|
    abort 'No auth token given' if args[:auth_token].nil?

    require_relative 'rake_helpers/canary_configuration'

    factory = ThinkstCanary::Factory.new(factory_auth: args[:auth_token])
    if factory.delete
      puts "Factory auth deleted successfully"
    else
      puts "Failed to delete factory auth"
    end
  end

  desc 'Create a Canary report called reports_access_details.docx'
  task create_reports_access_details: :environment do |_task, args|
    require_relative 'rake_helpers/canary_configuration'

    ##################
    # Create Factory
    puts 'Opening factory'

    factory = ThinkstCanary::Factory.new(
      factory_auth: ENV['CANARY_FACTORY_AUTH_TOKEN'],
      flock_id: ENV['CANARY_FLOCK_ID']
    )

    ##################
    # Create Token
    puts 'Creating token'

    original_file = Rails.root.join('docs', 'samples', 'canary_base.docx')

    token = factory.create_token(
      kind: 'doc-msword',
      memo: "Fake reports access details file on '#{ENV['ENV']}'",
      file: File.open(original_file)
    )

    ##################
    # Fetch Token file
    puts 'Fetching token and creating report'

    Stats::StatsReport.record_start('reports_access_details').tap do |report|
      report.document.attach(
        io: StringIO.new(token.download),
        filename: 'reports_access_details.docx'
      )
      report.update(status: 'completed', completed_at: Time.zone.now)
    end
  end
end
