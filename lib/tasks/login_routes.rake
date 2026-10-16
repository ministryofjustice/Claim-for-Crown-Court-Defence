require_relative 'rake_helpers/login_method_updater'

namespace :login_routes do
  def update_login_method(login_method, args, usage)
    raise "Use: #{usage}" if args.csv_path.blank?
    raise "File not found: #{args.csv_path}" unless File.exist?(args.csv_path)

    dry_run = args.dry_run != 'false'
    result = Tasks::RakeHelpers::LoginMethodUpdater.new(login_method, dry_run:).call(args.csv_path)
    report_login_method_update(result, login_method, dry_run)
  end

  def report_login_method_update(result, login_method, dry_run)
    puts '[DRY RUN] No changes made; pass false as the second argument to apply them' if dry_run
    puts "#{result.changed.size} user(s) #{'would be ' if dry_run}changed to #{login_method}, " \
         "#{result.unchanged} already #{login_method}"
    puts "Users #{dry_run ? 'that would change' : 'changed'}: #{result.changed.join(', ')}" if result.changed.any?
    puts "No user found for: #{result.not_found.join(', ')}" if result.not_found.any?
  end

  desc 'Change login method from legacy to entra for users (by email) in a CSV file; dry run unless dry_run is false'
  task :enable_entra, %i[csv_path dry_run] => :environment do |_task, args|
    update_login_method('entra', args, 'rake login_routes:enable_entra[path/to/emails.csv,false]')
  end

  desc 'Change login method from entra to legacy for users (by email) in a CSV file; dry run unless dry_run is false'
  task :revert_to_legacy, %i[csv_path dry_run] => :environment do |_task, args|
    update_login_method('legacy', args, 'rake login_routes:revert_to_legacy[path/to/emails.csv,false]')
  end
end
