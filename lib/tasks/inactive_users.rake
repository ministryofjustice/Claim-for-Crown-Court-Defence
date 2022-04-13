namespace :inactive_users do
  desc 'List inactive users'
  task list: :environment do
    CSV.open(Rails.root.join('tmp/inactive_users.csv'), 'wb') do |csv|
      csv << %w[
        id
        email
        last_sign_in_at
        current_sign_in_at
        created_at
        updated_at
        persona_type
      ]
      inactive_users = User.where('disabled_at IS NULL AND (last_sign_in_at < :limit OR (last_sign_in_at IS NULL AND created_at < :limit))', limit: 6.months.ago.to_date)
      inactive_users.each do |inactive_user|
        csv << [
          inactive_user.id,
          inactive_user.email,
          inactive_user.last_sign_in_at,
          inactive_user.current_sign_in_at,
          inactive_user.created_at,
          inactive_user.updated_at,
          inactive_user.persona_type
        ]
      end
      puts "Listed #{inactive_users.count} inactive users in tmp/inactive_users.csv"
    end
  end

  desc 'Disable inactive users'
  task disable: :environment do
    inactive_users = User.where('disabled_at IS NULL AND (last_sign_in_at < :limit OR (last_sign_in_at IS NULL AND created_at < :limit))', limit: 6.months.ago.to_date)
    puts "There are #{inactive_users.count} inactive users to be disabled"

    disabled_pre = User.where('disabled_at IS NOT NULL').count
    error_count = 0

    inactive_users.each do |inactive_user|
      inactive_user.update!(disabled_at: DateTime.now)
    rescue ActiveRecord::RecordInvalid
      error_count += 1
    end

    disabled_post = User.where('disabled_at IS NOT NULL').count
    puts "#{disabled_post - disabled_pre} inactive users have been disabled - run `rake inactive_users:list_disabled` for details"
    puts "Errors occurred when disabling #{error_count} users - run `rake inactive_users:list` for details" if error_count > 0
  end

  desc 'List disabled users'
  task list_disabled: :environment do
    CSV.open(Rails.root.join('tmp/disabled_users.csv'), 'wb') do |csv|
      csv << %w[
        id
        email
        last_sign_in_at
        current_sign_in_at
        created_at
        updated_at
        persona_type
        disabled_at
      ]
      disabled_users = User.where('disabled_at IS NOT NULL')
      disabled_users.each do |disabled_user|
        csv << [
          disabled_user.id,
          disabled_user.email,
          disabled_user.last_sign_in_at,
          disabled_user.current_sign_in_at,
          disabled_user.created_at,
          disabled_user.updated_at,
          disabled_user.persona_type,
          disabled_user.disabled_at
        ]
      end
      puts "Listed #{disabled_users.count} disabled users in tmp/disabled_users.csv"
    end
  end
end
