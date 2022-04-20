class UserManagement
  def self.inactive_provider_users
    User.where(last_sign_in_at: ..6.months.ago).or(
      User.where(last_sign_in_at: nil, created_at: ..6.months.ago)
    ).where(disabled_at: nil, persona_type: 'ExternalUser')
  end

  def self.disabled_provider_users
    User.where.not(disabled_at: nil).where(persona_type: 'ExternalUser')
  end

  def self.inactive_caseworker_users
    User.where(last_sign_in_at: ..6.months.ago).or(
      User.where(last_sign_in_at: nil, created_at: ..6.months.ago)
    ).where(disabled_at: nil, persona_type: 'CaseWorker')
  end

  def self.disabled_caseworker_users
    User.where.not(disabled_at: nil).where(persona_type: 'CaseWorker')
  end

  def self.create_csv_for(users, filename)
    CSV.open(Rails.root.join(filename), 'wb') do |csv|
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
      users.each do |user|
        csv << [
          user.id,
          user.email,
          user.last_sign_in_at,
          user.current_sign_in_at,
          user.created_at,
          user.updated_at,
          user.persona_type,
          user.disabled_at
        ]
      end
    end
  end

  def self.disable(users)
    error_count = 0
    users.each do |user|
      user.update!(disabled_at: DateTime.now)
    rescue ActiveRecord::RecordInvalid
      error_count += 1
    end
    return error_count
  end
end
