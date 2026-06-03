class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_load_and_authorize_resource

  LAA_ROLE_MAPPINGS = {
    'Caseworker' => 'case_worker',
    'Provider Management' => 'provider_management',
    'LAA Administrator' => 'admin'
  }.freeze

  def entra_mock
    handle_omniauth
  end

  def entra_id
    handle_omniauth
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

  def handle_omniauth
    auth = request.env['omniauth.auth']
    unless auth
      redirect_to new_user_session_path, alert: 'Authentication failed.'
      return
    end

    log_omniauth_payload(auth)

    user, error_message = find_existing_user_from_auth(auth)
    if user
      sign_in_and_redirect user, event: :authentication
    else
      message = error_message || 'Authentication failed.'
      redirect_to new_user_session_path, alert: message
    end
  end

  def log_omniauth_payload(auth)
    return unless Rails.env.development?

    auth_hash = auth.to_h
    credentials = auth_hash['credentials'] || {}
    credentials = credentials.except('token', 'id_token', 'refresh_token', :token, :id_token, :refresh_token)
    auth_hash['credentials'] = credentials

    payload = {
      event: 'omniauth_callback_full',
      auth: auth_hash
    }

    Rails.logger.info(payload.to_json)
  end

  def find_case_worker(info, raw)
    email = info.email.to_s.downcase
    user = User.find_by(email: email)
    return create_case_worker_from_auth(info, raw) if user.nil?
    return [nil, persona_mismatch_message(email, user.persona_type, 'CaseWorker')] if user.persona_type && user.persona_type != 'CaseWorker'

    update_case_worker_roles(user, raw)

    [user, nil]
  end

  def find_external_user(info, raw)
    email = info.email.to_s.downcase
    user = User.find_by(email: email)
    return create_external_user_from_auth(info, raw) if user.nil?
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
    email = info.email.to_s.downcase
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
    mapped = map_laa_roles(raw)
    return mapped if mapped.any?

    roles = Array(raw['roles']).map(&:to_s)
    roles = ['case_worker'] if roles.empty?
    roles = roles & CaseWorker::ROLES
    roles.empty? ? ['case_worker'] : roles
  end

  def extract_location(raw)
    location = raw['location'].to_s.strip
    location.empty? ? 'Nottingham' : location
  end

  def update_case_worker_roles(user, raw)
    return unless user.case_worker?

    mapped = map_laa_roles(raw)
    return if mapped.empty?

    current_roles = Array(user.persona.roles).map(&:to_s).sort
    desired_roles = mapped.sort
    return if current_roles == desired_roles

    user.persona.update!(roles: mapped)
  end

  def map_laa_roles(raw)
    laa_roles = Array(raw['LAA_ROLES']).map(&:to_s)
    return [] if laa_roles.empty?

    mapped = laa_roles.filter_map { |role| LAA_ROLE_MAPPINGS[role] }
    mapped = mapped & CaseWorker::ROLES
    mapped.uniq
  end

  def create_external_user_from_auth(info, raw)
    email = info.email.to_s.downcase
    return [nil, missing_user_message(email)] unless auto_provision_external_users?

    user = nil
    User.transaction do
      password = Devise.friendly_token.first(32)
      user = User.create!(
        first_name: info.first_name.presence || raw['first_name'].presence || 'Mock',
        last_name: info.last_name.presence || raw['last_name'].presence || 'ExternalUser',
        email: email.downcase,
        password: password,
        password_confirmation: password
      )

      provider = find_or_create_provider_from_auth(raw)
      external_user = ExternalUser.new(
        roles: extract_external_user_roles(raw, provider),
        supplier_number: extract_supplier_number(raw),
        provider: provider
      )
      external_user.user = user
      external_user.save!
    end

    [user, nil]
  rescue StandardError => e
    [nil, provision_failed_message(email, e)]
  end

  def auto_provision_external_users?
    Rails.env.development? || Rails.env.test?
  end

  def find_or_create_provider_from_auth(raw)
    name = extract_provider_name(raw)
    provider = Provider.find_by(name: name)
    return provider if provider

    provider_type = extract_provider_type(raw)
    roles = extract_provider_roles(raw, provider_type)

    Provider.create!(
      name: name,
      provider_type: provider_type,
      roles: roles,
      vat_registered: extract_provider_vat_registered(raw),
      firm_agfs_supplier_number: extract_firm_agfs_supplier_number(raw, provider_type, roles)
    )
  end

  def extract_external_user_roles(raw, provider)
    roles = Array(raw['roles']).map(&:to_s)
    roles = roles & ExternalUser::ROLES
    roles = available_external_user_roles(provider) & roles
    roles.empty? ? ['admin'] : roles
  end

  def extract_provider_name(raw)
    name = raw['provider_name'].to_s.strip
    name.empty? ? 'Mock Provider' : name
  end

  def extract_provider_type(raw)
    provider_type = raw['provider_type'].to_s.strip.downcase
    Provider::PROVIDER_TYPES.include?(provider_type) ? provider_type : 'firm'
  end

  def extract_provider_roles(raw, provider_type)
    roles = Array(raw['provider_roles']).map(&:to_s)
    roles = roles & Provider::ROLES
    roles = ['lgfs'] if roles.empty?
    normalize_provider_roles(roles, provider_type)
  end

  def normalize_provider_roles(roles, provider_type)
    roles = roles & Provider::ROLES
    return roles unless provider_type == 'firm'

    roles.include?('lgfs') ? roles : (roles + ['lgfs'])
  end

  def extract_provider_vat_registered(raw)
    value = raw['vat_registered']
    return true if value.nil?

    ActiveModel::Type::Boolean.new.cast(value)
  end

  def extract_firm_agfs_supplier_number(raw, provider_type, roles)
    return nil unless provider_type == 'firm'
    return nil unless roles.include?('agfs')

    number = raw['firm_agfs_supplier_number'].to_s.strip.upcase
    number.empty? ? 'ABCDE' : number
  end

  def extract_supplier_number(raw)
    number = raw['supplier_number'].to_s.strip.upcase
    number.empty? ? nil : number
  end

  def available_external_user_roles(provider)
    if provider.agfs? && provider.lgfs?
      %w[admin advocate litigator]
    elsif provider.agfs?
      %w[admin advocate]
    elsif provider.lgfs?
      %w[admin litigator]
    else
      []
    end
  end
end
