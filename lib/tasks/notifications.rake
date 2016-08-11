require Rails.root.join('lib', 'email_notification_cli')

namespace :notifications do

  # For a list of available options:
  #   rake notifications:send_email -- --help
  #
  desc 'Sends a test notification email (using GOV.uk notify service)'
  task :send_email => :environment do
    EmailNotificationCLI.new(ARGV).execute!
  end

end
