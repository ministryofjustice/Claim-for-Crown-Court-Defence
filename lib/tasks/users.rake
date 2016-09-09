namespace :users do
  desc 'List users and output to CSV file'
  task :list => :environment do
    require 'csv'
    user_ids = User.where(persona_type: 'ExternalUser').where('email not like ?', '%example.com').where('email not like ?', '%agfslgfs.com').pluck(:id)
    filename = File.join(Rails.root, 'tmp', 'user_list.csv')
    CSV.open(filename, 'w') do |csv|
      csv << [ 'Provider', 'Chamber/Firm', 'Supplier Number', 'First name', 'Last name', 'email', 'roles']
      user_ids.each do |user_id|
        user = User.find user_id
        csv << [ user.provider.name, user.provider.provider_type, user.provider.supplier_number, user.first_name, user.last_name, user.email, user.roles.join(', ')]
      end
    end
    puts "CSV file created: #{filename}"
  end

  desc 'Change the password of the internal user accounts'
  task :set_internal_password, [:password] => :environment do |_task, args|
    password = args.password || (raise 'Use: rake users:set_internal_password[pa$$w0rd]')

    User.where('email ILIKE any (array[?])', %w(%@example.com %@agfslgfs.com)).each do |user|
      user.password = password
      user.password_confirmation = password
      user.save || (raise 'Error: %s' % user.errors.messages)
    end

    puts 'Passwords changed.'
  end
end
