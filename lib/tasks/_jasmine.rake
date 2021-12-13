namespace :jasmine do
  desc 'Run node jasmine'
  task :run => :environment do
    puts 'Running Jasmine Specs...'
    system('npx jasmine-browser-runner runSpecs')
  end
end

if %w(development test).include? Rails.env
  task(:default).prerequisites.unshift('jasmine:run') if Gem.loaded_specs.key?('jasmine')
end
