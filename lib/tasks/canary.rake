namespace :canary do
  desc 'Create a Canary report called reports_access_details.docx'
  task :create_reports_access_details, [:file] => :environment do |_task, args|
    connection = Faraday.new(ENV['CANARY_URL'])
    auth_token = ENV['CANARY_AUTH_TOKEN']
    flock_id = ENV['CANARY_FLOCK_ID']

    original_file = Rails.root.join('docs', 'samples', 'test_file.docx')

    # Create Factory

    create_factory = connection.post(
      '/api/v1/canarytoken/create_factory',
      auth_token: auth_token,
      flock_id: flock_id,
      memo: "Example factory",
    )

    response = JSON.parse(create_factory.body)
    puts "Create factory: #{response['result']}"

    factory_auth = response['factory_auth']
    puts "Factory auth: #{factory_auth}"

    # Create Token

    create_token = connection.post(
      '/api/v1/canarytoken/factory/create',
      factory_auth: factory_auth,
      flock_id: flock_id,
      kind: 'doc-msword',
      memo: 'Another example Canary token',
      doc: "@#{original_filename}; type=application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    )

    response = JSON.parse(create_token.body)
    puts "Create token: #{response['result']}"

    pp response

    canarytoken = response['canarytoken']['canarytoken']

    # Fetch Token

    fetch_token = connection.get(
      '/api/v1/canarytoken/factory/download',
      {
        factory_auth: factory_auth,
        canarytoken: canarytoken
      }
    )

    File.open('/Users/josephhaig/workspace/Claim-for-Crown-Court-Defence/tmp/canary_token.docx', 'wb') { |fp| fp.write(fetch_token.body) }

    # Delete Token

    delete_factory = connection.delete(
      '/api/v1/canarytoken/delete_factory',
      {
        auth_token: auth_token,
        factory_auth: factory_auth
      }
    )

    response = JSON.parse(create_factory.body)

    puts "Delete factory: #{response['result']}"

    # report = Stats::StatsReport.record_start('reports_access_details')

    # canary = File.open(args[:file])
    # filename = 'reports_access_details.docx'
    # report.document.attach(io: canary, filename: filename)
    # report.update(status: 'completed', completed_at: Time.zone.now)
  end
end
