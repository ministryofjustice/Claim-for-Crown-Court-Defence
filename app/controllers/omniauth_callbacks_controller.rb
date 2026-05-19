class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_load_and_authorize_resource

  def entra_mock
    auth = request.env['omniauth.auth']
    unless auth
      redirect_to new_user_session_path, alert: 'Authentication failed.'
      return
    end

    user, error_message = find_existing_user_from_auth(auth)
    if user
      sign_in_and_redirect user, event: :authentication
    else
      message = error_message || 'Authentication failed.'
      redirect_to new_user_session_path, alert: message
    end
  end

  private

  def find_existing_user_from_auth(auth)
    info = auth.info
    raw = auth.extra&.raw_info || {}
    persona = raw['persona'] || 'CaseWorker'

    if persona == 'ExternalUser'
      find_external_user(info, raw)
    else
      find_case_worker(info, raw)
    end
  end

  def find_case_worker(info, raw)
    email = info.email
    user = User.find_by(email: email)
    return create_case_worker_from_auth(info, raw) if user.nil?
    return [nil, persona_mismatch_message(email, user.persona_type, 'CaseWorker')] if user.persona_type && user.persona_type != 'CaseWorker'

    [user, nil]
  end

  def find_external_user(info, _raw)
    email = info.email
    user = User.find_by(email: email)
    return [nil, missing_user_message(email)] if user.nil?
    return [nil, persona_mismatch_message(email, user.persona_type, 'ExternalUser')] if user.persona_type && user.persona_type != 'ExternalUser'

    [user, nil]
  end

  def missing_user_message(email)
    return nil unless Rails.env.development?

    "No user found for #{email}. Seed or create the user first."
  end

  def provision_failed_message(email, error)
    return nil unless Rails.env.development?

    "Failed to provision user for #{email}: #{error.message}"
  end

  def persona_mismatch_message(email, actual, expected)
    return nil unless Rails.env.development?

    "User #{email} is #{actual}, expected #{expected}."
  end

  def create_case_worker_from_auth(info, raw)
    email = info.email
    return [nil, missing_user_message(email)] unless auto_provision_case_workers?

    user = nil
    User.transaction do
      password = Devise.friendly_token.first(32)
      user = User.create!(
        first_name: info.first_name.presence || raw['first_name'].presence || 'Mock',
        last_name: info.last_name.presence || raw['last_name'].presence || 'Caseworker',
        email: email.downcase,
        password: password,
        password_confirmation: password
      )

      case_worker = CaseWorker.new(roles: extract_case_worker_roles(raw))
      case_worker.user = user
      case_worker.location = Location.find_or_create_by!(name: extract_location(raw))
      case_worker.save!
    end

    [user, nil]
  rescue StandardError => e
    [nil, provision_failed_message(email, e)]
  end

  def auto_provision_case_workers?
    Rails.env.development? || Rails.env.test?
  end

  def extract_case_worker_roles(raw)
    roles = Array(raw['roles']).map(&:to_s)
    roles = ['case_worker'] if roles.empty?
    roles = roles & CaseWorker::ROLES
    roles.empty? ? ['case_worker'] : roles
  end

  def extract_location(raw)
    location = raw['location'].to_s.strip
    location.empty? ? 'Nottingham' : location
  end
end
