namespace :brakeman do
  desc "Run Brakeman"
  task :run do
    require 'brakeman'
    require 'fileutils'
    require 'colorize'

    puts 'Running Brakeman...'
    dir = Rails.root.join('tmp','brakeman')
    FileUtils::mkdir_p(dir) unless File.dirname(dir)
    files ||= [File.join(dir, 'report.out')]
    tracker = Brakeman.run(:app_path => ".", quiet: true, output_files: files, exit_on_warn: true, print_report: false)

    unfiltered_warnings = (tracker.warnings - tracker.filtered_warnings)
    puts "New/Unfiltered warnings!".red if unfiltered_warnings.size > 0
    unfiltered_warnings.each { |warning| puts warning.warning_type.to_s.red }
    puts "Finished in #{(tracker.end_time - tracker.start_time).round(2)} seconds - warnings: #{tracker.warnings.size}, errors: #{tracker.errors.size}"
  end
end

if %w[development test].include?(Rails.env) && Gem.loaded_specs.key?('rubocop')
  task(:default).prerequisites.unshift(task('brakeman:run'))
end
