 namespace :data do
  namespace :migrate do

    desc 'Seed Disbursement Types'
    task :disbursement_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
    end

    desc 'set all admins to receive notification emails'
    task :set_notify => :environment do
      external_users = ExternalUser.admins
      external_users.each do |eu|
        eu.email_notification_of_message='true'
      end
    end


    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        'set_notify' => 'Set all external users with admin privileges to receive notification emails',
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end

