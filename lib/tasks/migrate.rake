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


    desc 'Set fee types quantities to decimal for SPF, WPF, RNF, CAV, WOA'
    task :set_quantity_is_decimal => :environment do
      %w{ SPF WPF RNF RNL CAV WOA }.each do |code|
        recs = Fee::BaseFeeType.where(code: code).where.not(quantity_is_decimal: true)
        recs.each do |rec| rec.update(quantity_is_decimal: true)
          puts "Quantity is decimal set to TRUE for fee type #{code}"
        end
      end
    end

    desc 'softly delete Travel costs disbursement type'
    task :delete_travel_costs => :environment do
      dt = DisbursementType.where(name: 'Travel costs').first
      dt.deleted_at = Time.now
      dt.save!
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

