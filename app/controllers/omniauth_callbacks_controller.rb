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

    if user.persona_type && user.persona_type != PERSONA_CASE_WORKER
      return [nil,
              persona_mismatch_message(email, user.persona_type,
                                       PERSONA_CASE_WORKER)]
    end

    update_case_worker_roles(user, raw)

    [user, nil]
  end

  def find_external_user(info, raw)
    email = info.email.to_s.downcase
    user = User.find_by(email: email)
    return create_external_user_from_auth(info, raw) if user.nil?

    if user.persona_type && user.persona_type != PERSONA_EXTERNAL_USER
      return [nil,
              persona_mismatch_message(email, user.persona_type,
                                       PERSONA_EXTERNAL_USER)]
    end

    update_external_user_roles(user, raw)

    [user, nil]
  end

  def find_super_admin(info)
    email = info.email.to_s.downcase
    user = User.find_by(email: email)
    return create_super_admin_from_auth(info) if user.nil?

    if user.persona_type && user.persona_type != PERSONA_SUPER_ADMIN
      return [nil,
              persona_mismatch_message(email, user.persona_type,
                                       PERSONA_SUPER_ADMIN)]
    end

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

    user = nil
    User.transaction do
      user = create_user_from_auth!(info, raw, email)

      case_worker = CaseWorker.new(roles: extract_case_worker_roles(raw))
      case_worker.user = user
      case_worker.location = Location.find_or_create_by!(name: default_case_worker_location)
      case_worker.save!
    end

    [user, nil]
  rescue StandardError => e
    [nil, provision_failed_message(email, e)]
  end

  def extract_case_worker_roles(raw)
    laa_roles = laa_roles_from_payload(raw)
    raise ArgumentError, 'Missing LAA_ROLES in auth payload' if laa_roles.empty?

    mapped = map_laa_internal_roles(raw)
    raise ArgumentError, 'No valid case worker roles found in LAA_ROLES' if mapped.empty?

    mapped
  end

  def default_case_worker_location
    'Nottingham'
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
    laa_roles = laa_roles_from_payload(raw)
    return [] if laa_roles.empty?

    mapped = laa_roles.filter_map { |role| LAA_INTERNAL_ROLE_MAPPINGS[role] }
    mapped &= CaseWorker::ROLES
    mapped.uniq
  end

  def map_laa_external_roles(raw)
    laa_roles = laa_roles_from_payload(raw)
    return [] if laa_roles.empty?

    mapped = laa_roles.filter_map { |role| LAA_EXTERNAL_ROLE_MAPPINGS[role] }
    mapped &= ExternalUser::ROLES
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
    laa_roles = laa_roles_from_payload(raw)
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

    user = nil
    User.transaction do
      provider = find_or_create_provider_for_external_user(raw)
      roles = extract_external_user_roles(raw, provider)
      supplier_number = if provider.chamber? && roles.include?('advocate')
                          extract_agfs_supplier_number_from_laa_accounts(raw)
                        end

      Devise.friendly_token.first(32)
      first_name = required_name(info, raw, 'first_name')
      last_name = required_name(info, raw, 'last_name')
      user = User.create!(
        first_name: first_name,
        last_name: last_name,
        email: email.downcase,
        **generated_auth_credentials
      )

      external_user = ExternalUser.new(
        roles: roles,
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

    user = nil
    User.transaction do
      user = create_user_from_auth!(info, {}, email)

      super_admin = SuperAdmin.new
      super_admin.user = user
      super_admin.save!
    end

    [user, nil]
  rescue StandardError => e
    [nil, provision_failed_message(email, e)]
  end

  def auto_create_providers_from_silas?
    ActiveModel::Type::Boolean.new.cast(ENV.fetch('AUTO_CREATE_PROVIDERS_FROM_SILAS', 'false'))
  end

  def required_name(info, raw, key)
    value = info.respond_to?(key) ? info.public_send(key) : nil
    value = value.presence || raw[key].presence
    raise ArgumentError, "Missing #{key} in auth payload" if value.blank?

    value
  end

  def create_user_from_auth!(info, raw, email)
    first_name = required_name(info, raw, 'first_name')
    last_name = required_name(info, raw, 'last_name')

    User.create!(
      first_name: first_name,
      last_name: last_name,
      email: email.downcase,
      **generated_auth_credentials
    )
  end

  def generated_auth_credentials
    generated_secret = Devise.friendly_token.first(32)

    {
      password: generated_secret,
      password_confirmation: generated_secret
    }
  end

  def separate_agfs_and_lgfs_supplier_numbers(raw)
    accounts = Array(raw['LAA_ACCOUNTS']).map { |value| value.to_s.strip.upcase }.reject(&:empty?)
    raise ArgumentError, 'Missing LAA_ACCOUNTS in auth payload' if accounts.empty?

    agfs_numbers = []
    lgfs_numbers = []

    accounts.each do |supplier_number|
      valid_agfs = ExternalUser::SUPPLIER_NUMBER_REGEX.match?(supplier_number)
      valid_lgfs = SupplierNumber::SUPPLIER_NUMBER_REGEX.match?(supplier_number)
      raise ArgumentError, "Invalid LAA_ACCOUNTS supplier number format: #{supplier_number}" unless valid_agfs || valid_lgfs

      agfs_numbers << supplier_number if valid_agfs
      lgfs_numbers << supplier_number if valid_lgfs
    end

    [agfs_numbers, lgfs_numbers]
  end

  def extract_agfs_supplier_number_from_laa_accounts(raw)
    agfs_numbers, = separate_agfs_and_lgfs_supplier_numbers(raw)

    # For external_user.supplier_number, only use AGFS numbers
    # LGFS supplier numbers are managed via the supplier_numbers table, not on external_user
    agfs_numbers.first
  end

  def find_or_create_provider_for_external_user(raw)
    firm_name = raw['FIRM_NAME'].to_s.strip
    raise ArgumentError, 'Missing FIRM_NAME in auth payload' if firm_name.blank?

    # Step 1: Try to find by FIRM_NAME
    provider = matched_provider_from_firm_name(firm_name)
    return provider if provider

    raise ArgumentError, "No provider found for FIRM_NAME: #{firm_name}" unless auto_create_providers_from_silas?

    # Step 2: Separate AGFS and LGFS supplier numbers
    agfs_numbers, lgfs_numbers = separate_agfs_and_lgfs_supplier_numbers(raw)

    # Step 3: If there are AGFS matches in external_users, reject and return error
    duplicate_agfs_supplier_number = agfs_numbers.find do |supplier_number|
      ExternalUser.where('UPPER(supplier_number) = ?', supplier_number).exists?
    end
    if duplicate_agfs_supplier_number
      raise ArgumentError, "AGFS supplier number #{duplicate_agfs_supplier_number} already registered. User may have registered another account in CCCD"
    end

    # Step 4: Check if any LGFS supplier_number exists in supplier_numbers table (find matching provider)
    matching_supplier_number = lgfs_numbers.find do |supplier_number|
      SupplierNumber.where('UPPER(supplier_number) = ?', supplier_number).exists?
    end
    if matching_supplier_number
      return SupplierNumber.where('UPPER(supplier_number) = ?', matching_supplier_number).first.provider
    end

    # Step 5-6: Create new provider with all LGFS supplier_numbers if no match found
    create_provider_with_supplier_numbers(raw, lgfs_numbers)
  end

  def matched_provider_from_firm_name(firm_name)
    normalized_firm_name = normalize_firm_name(firm_name)

    Provider.find_each do |provider|
      return provider if normalized_firm_name == normalize_firm_name(provider.name)
    end

    nil
  end

  def create_provider_with_supplier_numbers(raw, lgfs_supplier_numbers)
    name = extract_provider_name(raw)
    provider_type = extract_provider_type(raw)
    roles = extract_provider_roles(raw, provider_type)

    Provider.create!(
      name: name,
      provider_type: provider_type,
      roles: roles,
      vat_registered: extract_provider_vat_registered(raw),
      firm_agfs_supplier_number: extract_firm_agfs_supplier_number(raw, provider_type, roles),
      lgfs_supplier_numbers: lgfs_supplier_numbers.map do |supplier_number|
        SupplierNumber.new(supplier_number: supplier_number)
      end
    )
  end

  def normalize_firm_name(name)
    name.to_s.upcase
        .gsub('&', ' AND ')
        .gsub(/[^A-Z0-9]+/, ' ')
        .squeeze(' ')
        .strip
  end

  def extract_external_user_roles(raw, provider)
    laa_roles = laa_roles_from_payload(raw)
    raise ArgumentError, 'Missing LAA_ROLES in auth payload' if laa_roles.empty?

    mapped = map_laa_external_roles(raw)
    raise ArgumentError, 'No valid external user roles found in LAA_ROLES' if mapped.empty?

    roles = available_external_user_roles(provider) & mapped
    raise ArgumentError, 'No valid external user roles found in LAA_ROLES' if roles.empty?

    roles
  end

  def extract_provider_name(raw)
    name = raw['FIRM_NAME'].to_s.strip
    raise ArgumentError, 'Missing FIRM_NAME in auth payload' if name.empty?

    name
  end

  def extract_firm_agfs_supplier_number(raw, provider_type, roles)
    return nil unless provider_type == 'firm'
    return nil unless roles.include?('agfs')

    agfs_numbers, = separate_agfs_and_lgfs_supplier_numbers(raw)
    agfs_numbers.first
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

  # cannot determine provider_type from auth payload, so default to 'firm' for now. In future, if we have a way to determine provider_type from auth payload, we can implement that logic here.
  def extract_provider_type
    'firm'
  end

  # cannot determine provider roles from auth payload, so default to ['lgfs'] for now. In future, if we have a way to determine provider roles from auth payload, we can implement that logic here.
  def extract_provider_roles(provider_type)
    roles = ['lgfs']

    normalize_provider_roles(roles, provider_type)
  end

  def normalize_provider_roles(roles, provider_type)
    roles &= Provider::ROLES
    return roles unless provider_type == 'firm'

    roles.include?('lgfs') ? roles : (roles + ['lgfs'])
  end

  def laa_roles_from_payload(raw)
    Array(raw['LAA_ROLES']).map { |role| role.to_s.strip }.reject(&:empty?)
  end

  # cannot determine provider VAT registration status from auth payload, so default to true for now. In future, if we have a way to determine provider VAT registration status from auth payload, we can implement that logic here.
  def extract_provider_vat_registered
    true
  end
end
