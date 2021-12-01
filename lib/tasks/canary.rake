namespace :canary do
  desc 'Create a Canary report called reports_access_details.docx'
  task :create_reports_access_details, [:file] => :environment do |_task, args|
    ThinkstCanary.configure do |config|
      config.account_id = ENV['CANARY_ACCOUNT_ID']
      config.auth_token = ENV['CANARY_AUTH_TOKEN']
    end

    ##################
    # Create Factory
    puts 'Opening factory'

    # Create new factory:
    # factory = ThinkstCanary::FactoryGenerator.new.create_factory(
    #   flock_id: ENV['CANARY_FLOCK_ID'],
    #   memo: 'Example factory'
    # )

    # Use existing factory token:
    factory = ThinkstCanary::Factory.new(
      factory_auth: ENV['CANARY_FACTORY_AUTH_TOKEN'],
      flock_id: ENV['CANARY_FLOCK_ID'],
      memo: 'Example factory'
    )

    ##################
    # Create Token
    puts 'Creating token'

    original_file = Rails.root.join('docs', 'samples', 'test_file.docx')
    # original_file = Rails.root.join('features', 'examples', 'shorter_lorem.docx')

    token = factory.create_token(
      kind: 'doc-msword',
      memo: 'Another example Canary token',
      file: File.open(original_file)
    )

    ##################
    # Fetch Token file
    puts 'Fetching token and writing to file'

    File.open('tmp/test_token.docx', 'wb') do |file|
      file.puts token.download
    end

    # Fetch Token
    # TODO
  end
end
