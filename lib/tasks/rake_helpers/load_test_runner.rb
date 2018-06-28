module RakeHelpers

  class LoadTestRunner

    def initialize
      WebMock.allow_net_connect!
    end

    def run
      puts "Starting load test.....".colorize(:green)
      Dir.chdir LoadTestSetupChecker::WRAPPER_DIR
      num_claims = get_num_claims
      puts "#{Time.now.strftime("%H:%M:%S  ")} There are #{num_claims} on the system before starting the test"
      load_test_thread = Thread.new { run_load_test }
      continue = true

      while continue
        sleep 30
        latest_num_claims = get_num_claims
        continue = false unless latest_num_claims > num_claims
        num_claims = latest_num_claims
        puts "#{Time.now.strftime("%H:%M:%S  ")} Number of claims: #{num_claims}"
      end

      puts "No new claims have been created in the last 30 seconds - program terminating"
      load_test_thread.kill
    end

    private

    def run_load_test
      command = 'tsung -f ./config/project/adp/xml/staging-gradual-create_guilty_plea.xml -l ./config/project/adp/log start'
      IO.popen(command) do |pipe|
        puts pipe.read
      end
    end


    def get_num_claims
      JSON.parse(RestClient.get 'staging-adp.dsd.io/healthcheck.json')['num_claims']
    end

  end
end