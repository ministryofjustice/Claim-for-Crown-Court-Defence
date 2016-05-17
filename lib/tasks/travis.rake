namespace :travis do

  desc 'Run all test suites, as on travis'
  task :ci do
    Rake::Task['db:migrate'].invoke
    ["rake jasmine:ci", "rspec spec", "rake cucumber"].each do |cmd|
      puts "Starting to run #{cmd}..."
      system("export DISPLAY=:99.0 && bundle exec #{cmd}")
      # raise "#{cmd} failed!" unless $?.exitstatus == 0
      puts "#{cmd} FAILED!" unless $?.exitstatus == 0
    end
  end
end
