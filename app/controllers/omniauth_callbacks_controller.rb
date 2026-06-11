class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_load_and_authorize_resource

  LAA_INTERNAL_ROLE_MAPPINGS = {
    'Caseworker' => 'case_worker',
    'Provider Management' => 'provider_management',
    'LAA Administrator' => 'admin'
  }.freeze

  LAA_EXTERNAL_ROLE_MAPPINGS = {
    'Advocate' => 'advocate',
    'Litigator' => 'litigator',
    'Advocate Admin' => 'admin',
    'Litigator Admin' => 'admin'
  }.freeze

  LAA_SUPER_ADMIN_ROLE = 'Super Administrator'

  PERSONA_CASE_WORKER = CaseWorker.name
  PERSONA_EXTERNAL_USER = ExternalUser.name
  PERSONA_SUPER_ADMIN = SuperAdmin.name

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
    email = info.email.to_s.downcase
    existing_user = User.find_by(email: email)
    persona = existing_user&.persona_type || persona_from_laa_roles(raw) || raw['persona'] || PERSONA_CASE_WORKER

    if persona == PERSONA_SUPER_ADMIN
      find_super_admin(info, raw)
    elsif persona == PERSONA_EXTERNAL_USER
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

    return [nil, persona_mismatch_message(email, user.persona_type, PERSONA_CASE_WORKER)] if user.persona_type && user.persona_type != PERSONA_CASE_WORKER

    update_case_worker_roles(user, raw)

    [user, nil]
  end

  def find_external_user(info, raw)
    email = info.email.to_s.downcase
    user = User.find_by(email: email)
    return create_external_user_from_auth(info, raw) if user.nil?

    return [nil, persona_mismatch_message(email, user.persona_type, PERSONA_EXTERNAL_USER)] if user.persona_type && user.persona_type != PERSONA_EXTERNAL_USER

    update_external_user_roles(user, raw)

    [user, nil]
  end

  def find_super_admin(info, raw)
    email = info.email.to_s.downcase
    user = User.find_by(email: email)
    return create_super_admin_from_auth(info) if user.nil?

    return [nil, persona_mismatch_message(email, user.persona_type, PERSONA_SUPER_ADMIN)] if user.persona_type && user.persona_type != PERSONA_SUPER_ADMIN

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

    "Persona mismatch for #{email}: stored #{actual || 'none'}, expected #{expected}. Login blocked."
  end

  def create_case_worker_from_auth(info, raw)
    email = info.email.to_s.downcase
    return [nil, missing_user_message(email)] unless auto_provision_case_workers?

    user = nil
    User.transaction do
      password = Devise.friendly_token.first(32)
      first_name = required_name(info, raw, 'first_name')
      last_name = required_name(info, raw, 'last_name')
      user = User.create!(
        first_name: first_name,
        last_name: last_name,
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
    mapped = map_laa_internal_roles(raw)
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
    return if user.persona_type == PERSONA_SUPER_ADMIN
    return unless user.case_worker?

    mapped = map_laa_internal_roles(raw)
    return if mapped.empty?

    current_roles = Array(user.persona.roles).map(&:to_s).sort
    desired_roles = mapped.sort
    return if current_roles == desired_roles

    user.persona.update!(roles: mapped)
  end


  def map_laa_internal_roles(raw)
    laa_roles = Array(raw['LAA_ROLES']).map(&:to_s)
    return [] if laa_roles.empty?

    mapped = laa_roles.filter_map { |role| LAA_INTERNAL_ROLE_MAPPINGS[role] }
    mapped = mapped & CaseWorker::ROLES
    mapped.uniq
  end

  def map_laa_external_roles(raw)
    laa_roles = Array(raw['LAA_ROLES']).map(&:to_s)
    return [] if laa_roles.empty?

    mapped = laa_roles.filter_map { |role| LAA_EXTERNAL_ROLE_MAPPINGS[role] }
    mapped = mapped & ExternalUser::ROLES
    mapped.uniq
  end

  def update_external_user_roles(user, raw)
    return if user.persona_type == PERSONA_SUPER_ADMIN
    return unless user.external_user?

    mapped = map_laa_external_roles(raw)
    return if mapped.empty?

    current_roles = Array(user.persona.roles).map(&:to_s).sort
    desired_roles = mapped.sort
    return if current_roles == desired_roles

    user.persona.update!(roles: mapped)
  end


  def persona_from_laa_roles(raw)
    laa_roles = Array(raw['LAA_ROLES']).map(&:to_s)
    return nil if laa_roles.empty?
    return PERSONA_SUPER_ADMIN if laa_roles.include?(LAA_SUPER_ADMIN_ROLE)

    external_roles = map_laa_external_roles(raw)
    return PERSONA_EXTERNAL_USER if external_roles.any?

    internal_roles = map_laa_internal_roles(raw)
    return PERSONA_CASE_WORKER if internal_roles.any?

    nil
  end

  def create_external_user_from_auth(info, raw)
    email = info.email.to_s.downcase
    return [nil, missing_user_message(email)] unless auto_provision_external_users?

    user = nil
    User.transaction do
      supplier_number = extract_supplier_number_from_laa_accounts(raw)
      provider = find_provider_from_firm_name(raw)
      validate_supplier_number_matches_provider!(supplier_number, provider)

      password = Devise.friendly_token.first(32)
      first_name = required_name(info, raw, 'first_name')
      last_name = required_name(info, raw, 'last_name')
      user = User.create!(
        first_name: first_name,
        last_name: last_name,
        email: email.downcase,
        password: password,
        password_confirmation: password
      )

      external_user = ExternalUser.new(
        roles: extract_external_user_roles(raw, provider),
        supplier_number: supplier_number,
        provider: provider
      )
      external_user.user = user
      external_user.save!
    end

    [user, nil]
  rescue StandardError => e
    [nil, provision_failed_message(email, e)]
  end

  def create_super_admin_from_auth(info)
    email = info.email.to_s.downcase
    return [nil, missing_user_message(email)] unless auto_provision_super_admins?

    user = nil
    User.transaction do
      password = Devise.friendly_token.first(32)
      first_name = required_name(info, {}, 'first_name')
      last_name = required_name(info, {}, 'last_name')
      user = User.create!(
        first_name: first_name,
        last_name: last_name,
        email: email.downcase,
        password: password,
        password_confirmation: password
      )

      super_admin = SuperAdmin.new
      super_admin.user = user
      super_admin.save!
    end

    [user, nil]
  rescue StandardError => e
    [nil, provision_failed_message(email, e)]
  end

  def auto_provision_super_admins?
    Rails.env.development? || Rails.env.test?
  end

  def required_name(info, raw, key)
    value = info.respond_to?(key) ? info.public_send(key) : nil
    value = value.presence || raw[key].presence
    raise ArgumentError, "Missing #{key} in auth payload" if value.blank?

    value
  end

  def auto_provision_external_users?
    Rails.env.development? || Rails.env.test?
  end

  def extract_supplier_number_from_laa_accounts(raw)
    accounts = Array(raw['LAA_ACCOUNTS']).map { |value| value.to_s.strip.upcase }.reject(&:empty?)
    supplier_number = accounts.first
    raise ArgumentError, 'Missing LAA_ACCOUNTS in auth payload' if supplier_number.blank?

    valid_agfs = ExternalUser::SUPPLIER_NUMBER_REGEX.match?(supplier_number)
    valid_lgfs = SupplierNumber::SUPPLIER_NUMBER_REGEX.match?(supplier_number)
    raise ArgumentError, "Invalid LAA_ACCOUNTS supplier number format: #{supplier_number}" unless valid_agfs || valid_lgfs

    supplier_number
  end

  def find_provider_from_firm_name(raw)
    firm_name = raw['FIRM_NAME'].to_s.strip
    raise ArgumentError, 'Missing FIRM_NAME in auth payload' if firm_name.blank?

    provider = Provider.find_by('LOWER(name) = ?', firm_name.downcase)
    raise ArgumentError, "No provider found for FIRM_NAME: #{firm_name}" if provider.nil?

    provider
  end

  def validate_supplier_number_matches_provider!(supplier_number, provider)
    provider_firm_agfs = provider.firm_agfs_supplier_number.to_s.upcase
    lgfs_match = provider.lgfs_supplier_numbers.where('UPPER(supplier_number) = ?', supplier_number).exists?
    external_user_match = provider.external_users.where('UPPER(supplier_number) = ?', supplier_number).exists?
    agfs_match = provider_firm_agfs.present? && provider_firm_agfs == supplier_number
    return if lgfs_match || external_user_match || agfs_match

    raise ArgumentError, "LAA_ACCOUNTS supplier number #{supplier_number} does not match existing records for provider #{provider.name}"
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
    mapped = map_laa_external_roles(raw)
    return mapped if mapped.any?

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
