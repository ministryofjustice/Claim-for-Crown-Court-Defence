require_relative 'rake_helpers/user_management.rb'

namespace :inactive_users do
  desc 'List inactive users'
  task list: :environment do
    inactive_users = UserManagement.inactive_users
    inactive_users_file = "tmp/inactive_users_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
    UserManagement.create_csv_for(inactive_users, inactive_users_file)
    puts "Listed #{inactive_users.count} inactive users in #{inactive_users_file}"
  end

  desc 'List disabled users'
  task list_disabled: :environment do
    disabled_users = UserManagement.disabled_users
    disabled_users_file = "tmp/disabled_users_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
    UserManagement.create_csv_for(disabled_users, disabled_users_file)
    puts "Listed #{disabled_users.count} disabled users in #{disabled_users_file}"
  end

  desc 'Disable inactive users'
  task disable: :environment do
    inactive_users = UserManagement.inactive_users
    puts "There are #{inactive_users.count} inactive users to be disabled"

    disabled_pre = UserManagement.disabled_users.count
    error_count = 0

    inactive_users.each do |inactive_user|
      inactive_user.update!(disabled_at: DateTime.now)
    rescue ActiveRecord::RecordInvalid
      error_count += 1
    end

    disabled_post = UserManagement.disabled_users.count
    puts "#{disabled_post - disabled_pre} inactive users have been disabled - run `rake inactive_users:list_disabled` for details"
    puts "Errors occurred when disabling #{error_count} users - run `rake inactive_users:list` for details" if error_count > 0
  end
end
