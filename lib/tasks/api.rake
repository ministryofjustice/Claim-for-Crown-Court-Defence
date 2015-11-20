namespace :api do

  desc "Smoke test for the REST API"

  task :smoke_test, [:io] => :environment do |task,args|
    Rake::Task['claims:sample_users'].invoke

    require "#{Rails.root.join('lib','api_test_client')}"

    # optional argument to provide a different output stream
    begin
      io = (args[:io] && Object.const_get(args[:io])) || STDOUT
    rescue NameError
      raise ArgumentError, 'Invalid IO provided'
    end

    api_client = ApiTestClient.new()
    api_client.run

    if api_client.success
      io.puts "[+] success"
      io.puts api_client.messages.join("\n")
    else
      io.puts "[-] errors"
      io.puts api_client.errors.join("\n")
      io.puts api_client.full_error_messages.join("\n")
      raise "API Error: ADP RESTful API smoke test failure!"
    end

  end

end