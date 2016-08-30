
# This rake task will enable you to send a standard message notification email to an address
# from dev in order to test layout, etc.

# Pass claim_id, and email address as parameters, e.g.
#    rake mail:test[16201,xx@stephenrichards.eu]

# You will need to set up smtp credentials as environment variables beforehand (see config/environments/development.rb), and
# change the following mail config settings in that file:
#
#   config.action_mailer.perform_deliveries = true
#   config.action_mailer.delivery_method = :smtp
#

namespace :mail do
  desc 'send test mail to address given as param'
  task :test, [:claim_id, :email_address] => :environment do | _task, args|
    raise "Only run in dev mode" unless Rails.env.development?
    claim = Claim::BaseClaim.find args[:claim_id]
    original_email = claim.creator.email
    claim.creator.user.email = args[:email_address]
    claim.creator.user.save!
    claim.reload
    puts ">>>>>>>>>>>>>> delivering mail to #{args[:email_address]} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    MessageNotificationMailer.notify_message(claim).deliver
    puts ">>>>>>>>>>>>>> mail delivered #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    claim.creator.user.email = original_email
    claim.creator.user.save!
  end
end

