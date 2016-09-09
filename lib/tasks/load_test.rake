

namespace :test do
  desc 'Runs pre-configured load test on STAGING'
  task :load => :environment do
    require_relative 'rake_helpers/load_test_setup_checker'
    require_relative 'rake_helpers/load_test_runner'
    include RakeHelpers

    LoadTestRunner.new.run if LoadTestSetupChecker.new.setup?
  end
end
