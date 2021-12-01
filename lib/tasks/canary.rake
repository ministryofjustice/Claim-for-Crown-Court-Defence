namespace :canary do
  desc 'Create a Canary report called reports_access_details.docx'
  task :create_reports_access_details, [:file] => :environment do |_task, args|
    # original_file = Rails.root.join('docs', 'samples', 'test_file.docx')

    ThinkstCanary.configure do |config|
      config.account_id = ENV['CANARY_ACCOUNT_ID']
      config.auth_token = ENV['CANARY_AUTH_TOKEN']
    end

    # Create Factory

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

    token = factory.create_token(
      memo: 'Example token',
      kind: 'http'
    )

    binding.pry

    # Fetch Token
    # TODO
  end
end
