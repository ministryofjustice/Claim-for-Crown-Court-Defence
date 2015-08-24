namespace :api do

  desc "Smoke test for the REST API"

  task :smoke_test, [:io] => :environment do |task,args|

    require "#{Rails.root.join('lib','api_test_client')}"

    # optional argument to provide a different output stream
    begin
      io = (args[:io] && Object.const_get(args[:io])) || STDOUT
    rescue NameError
      raise ArgumentError, 'Invalid IO provided'
    end

    client_test = ApiTestClient.new()

    if client_test.success
      status = 0
      io.puts "[+] success"
      io.puts client_test.messages.join("\n")
    else
      status = 1
      io.puts "[-] errors"
      io.puts client_test.errors.join("\n")
    end

    io.puts status

  end

end