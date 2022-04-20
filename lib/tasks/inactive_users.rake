require_relative 'rake_helpers/user_management.rb'

namespace :inactive_users do
  desc 'List inactive provider users'
  task list_providers: :environment do
    inactive_users = UserManagement.inactive_provider_users
    inactive_users_file = "tmp/inactive_provider_users_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
    UserManagement.create_csv_for(inactive_users, inactive_users_file)
    puts "Listed #{inactive_users.count} inactive provider users in #{inactive_users_file}"
  end

  desc 'List inactive caseworker users'
  task list_caseworkers: :environment do
    inactive_users = UserManagement.inactive_caseworker_users
    inactive_users_file = "tmp/inactive_caseworker_users_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
    UserManagement.create_csv_for(inactive_users, inactive_users_file)
    puts "Listed #{inactive_users.count} inactive caseworker users in #{inactive_users_file}"
  end

  desc 'List disabled provider users'
  task list_disabled_providers: :environment do
    disabled_users = UserManagement.disabled_provider_users
    disabled_users_file = "tmp/disabled_provider_users_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
    UserManagement.create_csv_for(disabled_users, disabled_users_file)
    puts "Listed #{disabled_users.count} disabled provider users in #{disabled_users_file}"
  end

  desc 'List disabled caseworker users'
  task list_disabled_caseworkers: :environment do
    disabled_users = UserManagement.disabled_caseworker_users
    disabled_users_file = "tmp/disabled_caseworker_users_#{DateTime.now.strftime("%Y%m%d%H%M%S")}.csv"
    UserManagement.create_csv_for(disabled_users, disabled_users_file)
    puts "Listed #{disabled_users.count} disabled caseworker users in #{disabled_users_file}"
  end

  desc 'Disable inactive provider users'
  task disable_providers: :environment do
    inactive_users = UserManagement.inactive_provider_users
    puts "There are #{inactive_users.count} inactive provider users to be disabled"
    disabled_pre = UserManagement.disabled_provider_users.count
    error_count = UserManagement.disable(inactive_users)
    disabled_post = UserManagement.disabled_provider_users.count
    puts "#{disabled_post - disabled_pre} inactive provider users have been disabled - run `rake inactive_users:list_disabled_providers` for details"
    puts "Errors occurred when disabling #{error_count} provider users - run `rake inactive_users:list_providers` for details" if error_count > 0
  end

  desc 'Disable inactive caseworker users'
  task disable_caseworkers: :environment do
    inactive_users = UserManagement.inactive_caseworker_users
    puts "There are #{inactive_users.count} inactive caseworker users to be disabled"
    disabled_pre = UserManagement.disabled_caseworker_users.count
    error_count = UserManagement.disable(inactive_users)
    disabled_post = UserManagement.disabled_caseworker_users.count
    puts "#{disabled_post - disabled_pre} inactive caseworker users have been disabled - run `rake inactive_users:list_disabled_caseworkers` for details"
    puts "Errors occurred when disabling #{error_count} caseworker users - run `rake inactive_users:list_caseworkers` for details" if error_count > 0
  end
end
