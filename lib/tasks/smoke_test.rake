namespace :smoke_test do
  desc 'Run the smoke tests for the REST API'
  task :api, [:io] => :environment do |_, args|
    
    begin
      io = (args[:io] && Object.const_get(args[:io])) || STDOUT
    rescue NameError
      raise ArgumentError, 'Invalid IO provided'
    end

    test_suite = TestSuite::Api.new
    success    = test_suite.run

    if success
      io.puts "[+] Success"
    else
      io.puts "[-] Errors in test suite\n"
      io.puts test_suite.errors.join("\n")
    end
  end
end