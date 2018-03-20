namespace :brakeman do
  desc "Run Brakeman"
  task :run do |t, args|
    require 'brakeman'
    require 'fileutils'

    puts 'Running Brakeman...'
    dir = Rails.root.join('tmp','brakeman')
    FileUtils::mkdir_p(dir) unless File.dirname(dir)
    files ||= [File.join(dir, 'report.out')]
    Brakeman.run(:app_path => ".", quiet: true, output_files: files)
  end
end

if %w[development test].include?(Rails.env) && Gem.loaded_specs.key?('rubocop')
  task(:default).prerequisites.unshift(task('brakeman:run'))
end
