namespace :brakeman do
  desc "Run Brakeman"
  task :run do
    require 'brakeman'
    require 'fileutils'
    require 'colorize'

    spinner = TTY::Spinner.new("[:spinner] Running Brakeman...")
    spinner.run do
      system("brakeman -o #{report_output.join(' -o ')} -q")
      spinner.success
    end

    content = File.read(report_output.second)
    report = JSON.parse(content, object_class: OpenStruct)
    time_taken = (report.scan_info.end_time.to_datetime.to_f - report.scan_info.start_time.to_datetime.to_f).to_i

    if report.warnings.size > 0
      puts "New warnings: #{report.warnings.size} - see #{report_output.first} for details".red
    else
      puts "No new warnings".green
    end
    puts "Finished in #{time_taken} seconds"
    puts "warnings: #{report.ignored_warnings.size}, new warnings: #{report.warnings.size}, errors: #{report.errors.size}"
    exit 1 if report.warnings.any?
  end

  def report_output
    return @report_output unless @report_output.nil?
    dir = Rails.root.join('tmp','brakeman')
    FileUtils::mkdir_p(dir) unless File.dirname(dir)
    @report_output = [File.join(dir, 'report.out'), File.join(dir, 'report.json')]
  end
end

if %w[development test].include?(Rails.env) && Gem.loaded_specs.key?('brakeman')
  task(:default).prerequisites.unshift(task('brakeman:run'))
end
