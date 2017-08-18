namespace :ci do
  desc 'Run all tests in application-defined order, intended for CI test suite run'
  task :test_suite => :environment do
    raise 'The test suite should only be run in development and test environments!' unless Rails.env.in? %w(development test)
    puts 'Info: Running Test Suite'.green
    Rake::Task['rubocop'].invoke
    Rake::Task['jasmine:ci'].invoke
    Rake::Task['spec'].invoke
    puts 'Info: Sleeping for five seconds to give CPU time to cool down and perhaps not fail on the cuke tasks because drop down lists aren''t populated fast enough.'.green
    sleep 5
    Rake::Task['cucumber'].invoke
  end
end

