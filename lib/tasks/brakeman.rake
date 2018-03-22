namespace :brakeman do
  desc "Run Brakeman"
  task :run do
    require 'brakeman'
    require 'fileutils'
    require 'colorize'

    puts 'Running Brakeman...'
    tracker = Brakeman.run(:app_path => ".", quiet: true, output_files: report_file, exit_on_warn: true, print_report: false)
    unignored_warnings = tracker.warnings.reject do |warning|
      warning.fingerprint.in?(tracker.ignored_filter.ignored_warnings.map(&:fingerprint))
    end

    if unignored_warnings.count > 0
      puts "New warnings: #{unignored_warnings.count} - see #{report_file.first} for details".red
    else
      puts "No new warnings".green
    end

    puts "Finished in #{(tracker.end_time - tracker.start_time).round(2)} seconds - warnings: #{tracker.warnings.size}, new warnings: #{unignored_warnings.count}, errors: #{tracker.errors.size}"
    exit 1 if unignored_warnings.count > 0
  end

  def report_file
    return @report_file unless @report_file.nil?
    dir = Rails.root.join('tmp','brakeman')
    FileUtils::mkdir_p(dir) unless File.dirname(dir)
    @report_file = [File.join(dir, 'report.out')]
  end
end

if %w[development test].include?(Rails.env) && Gem.loaded_specs.key?('brakeman')
  task(:default).prerequisites.unshift(task('brakeman:run'))
end
