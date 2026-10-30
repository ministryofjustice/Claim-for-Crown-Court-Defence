# rubocop:disable-next Metrics/ClassLength
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_load_and_authorize_resource

  PERSONA_CASE_WORKER = CaseWorker.name
  PERSONA_EXTERNAL_USER = ExternalUser.name
  PERSONA_SUPER_ADMIN = SuperAdmin.name
  SUPPLIER_NUMBER_CASE_INSENSITIVE_WHERE = 'UPPER(supplier_number) = ?'.freeze

  def entra_mock
    handle_omniauth
  end

  def entra_id
    handle_omniauth
  end

  def failure
    DualLogin.new(session).clear
    redirect_to_authentication_failure
  end

  private

  def find_existing_user_from_auth(auth)
    info = auth.info
    raw = auth.extra&.raw_info || {}
    user = User.find_by(email: info.email.to_s.downcase)

    find_user_by_persona(user, info, raw)
  rescue Silas::Roles::NoApplicableRoles, ActiveRecord::RecordInvalid
    [nil, authentication_failed_message]
  end

  def handle_omniauth
    flow = DualLogin.new(session)
    unless flow.allowed?(LoginRoute::ENTRA)
      return redirect_to sign_in_path, alert: I18n.t('session_routing.unavailable')
    end

    auth = request.env['omniauth.auth']
    return redirect_to_authentication_failure unless auth
    return redirect_to_email_mismatch unless identified_email_matches?(auth.info.email)

    complete_sign_in(auth)
  ensure
    flow.clear
  end

  def complete_sign_in(auth)
    log_omniauth_payload(auth)
    user, error_message = find_existing_user_from_auth(auth)
    return sign_in_and_redirect(user, event: :authentication) if user

    redirect_to sign_in_path, alert: error_message || authentication_failed_message
  end

  def redirect_to_authentication_failure
    redirect_to sign_in_path, alert: authentication_failed_message
  end

  def redirect_to_email_mismatch
    redirect_to sign_in_path, alert: I18n.t('omniauth_callbacks.email_mismatch')
  end

  def authentication_failed_message
    I18n.t('omniauth_callbacks.authentication_failed')
  end

  def identified_email_matches?(email)
    identified_email = DualLogin.new(session).email
    identified_email.present? && identified_email == email.to_s.strip.downcase
  end

  def resolved_persona(user, raw)
    user&.persona_type || Silas::Roles.new(raw).persona_type || raw['persona'] || PERSONA_CASE_WORKER
  end

  def find_user_by_persona(user, info, raw)
    case resolved_persona(user, raw)
    when PERSONA_SUPER_ADMIN
      find_super_admin(user, info)
    when PERSONA_EXTERNAL_USER
      find_external_user(user, info, raw)
    else
      find_case_worker(user, info, raw)
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

  def find_case_worker(user, info, raw)
    email = info.email.to_s.downcase
    return create_case_worker_from_auth(info, raw) if user.nil?

    if user.persona_type && user.persona_type != PERSONA_CASE_WORKER
      return [nil,
              persona_mismatch_message(email, user.persona_type,
                                       PERSONA_CASE_WORKER)]
    end

    Silas::Roles.new(raw).sync!(user)

    [user, nil]
  end

  def find_external_user(user, info, raw)
    email = info.email.to_s.downcase
    return create_external_user_from_auth(info, raw) if user.nil?

    if user.persona_type && user.persona_type != PERSONA_EXTERNAL_USER
      return [nil,
              persona_mismatch_message(email, user.persona_type,
                                       PERSONA_EXTERNAL_USER)]
    end

    Silas::Roles.new(raw).sync!(user)

    [user, nil]
  end

  def find_super_admin(user, info)
    email = info.email.to_s.downcase
    return create_super_admin_from_auth(info) if user.nil?

    if user.persona_type && user.persona_type != PERSONA_SUPER_ADMIN
      return [nil,
              persona_mismatch_message(email, user.persona_type,
                                       PERSONA_SUPER_ADMIN)]
    end

    [user, nil]
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

    provision_user(email) do
      user = create_user_from_auth!(info, raw, email)
      create_case_worker_persona!(user, raw)
      user
    end
  end

  def create_case_worker_persona!(user, raw)
    case_worker = CaseWorker.new(roles: extract_case_worker_roles(raw))
    case_worker.user = user
    case_worker.location = Location.find_or_create_by!(name: default_case_worker_location)
    case_worker.save!
  end

  def extract_case_worker_roles(raw)
    role_mapping = Silas::Roles.new(raw)
    raise ArgumentError, 'Missing LAA_ROLES in auth payload' if role_mapping.empty?

    mapped = role_mapping.case_worker_roles
    raise ArgumentError, 'No valid case worker roles found in LAA_ROLES' if mapped.empty?

    mapped
  end

  def default_case_worker_location
    'Nottingham'
  end

  def create_external_user_from_auth(info, raw)
    email = info.email.to_s.downcase

    provision_user(email) do
      provider = find_or_create_provider_for_external_user(raw)
      roles = extract_external_user_roles(raw, provider)
      supplier_number = chamber_advocate_supplier_number(provider, roles, raw)
      user = create_user_from_auth!(info, raw, email)
      create_external_user_persona!(user, roles, supplier_number, provider)
      user
    end
  end

  def chamber_advocate_supplier_number(provider, roles, raw)
    return unless provider.chamber? && roles.include?('advocate')

    extract_agfs_supplier_number_from_laa_accounts(raw)
  end

  def create_external_user_persona!(user, roles, supplier_number, provider)
    external_user = ExternalUser.new(
      roles: roles,
      supplier_number: supplier_number,
      provider: provider
    )
    external_user.user = user
    external_user.save!
  end

  def create_super_admin_from_auth(info)
    email = info.email.to_s.downcase

    provision_user(email) do
      user = create_user_from_auth!(info, {}, email)
      create_super_admin_persona!(user)
      user
    end
  end

  def create_super_admin_persona!(user)
    super_admin = SuperAdmin.new
    super_admin.user = user
    super_admin.save!
  end

  def provision_user(email)
    user = nil
    User.transaction { user = yield }

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
    accounts = normalized_supplier_numbers(raw)
    raise ArgumentError, 'Missing LAA_ACCOUNTS in auth payload' if accounts.empty?

    accounts.each_with_object([[], []]) do |supplier_number, (agfs_numbers, lgfs_numbers)|
      valid_agfs, valid_lgfs = supplier_number_types(supplier_number)
      ensure_valid_supplier_number!(supplier_number, valid_agfs, valid_lgfs)

      agfs_numbers << supplier_number if valid_agfs
      lgfs_numbers << supplier_number if valid_lgfs
    end
  end

  def normalized_supplier_numbers(raw)
    Array(raw['LAA_ACCOUNTS']).map { |value| value.to_s.strip.upcase }.reject(&:empty?)
  end

  def supplier_number_types(supplier_number)
    [
      ExternalUser::SUPPLIER_NUMBER_REGEX.match?(supplier_number),
      SupplierNumber::SUPPLIER_NUMBER_REGEX.match?(supplier_number)
    ]
  end

  def ensure_valid_supplier_number!(supplier_number, valid_agfs, valid_lgfs)
    return if valid_agfs || valid_lgfs

    raise ArgumentError, "Invalid LAA_ACCOUNTS supplier number format: #{supplier_number}"
  end

  def extract_agfs_supplier_number_from_laa_accounts(raw)
    agfs_numbers, = separate_agfs_and_lgfs_supplier_numbers(raw)

    # For external_user.supplier_number, only use AGFS numbers
    # LGFS supplier numbers are managed via the supplier_numbers table, not on external_user
    agfs_numbers.first
  end

  def find_or_create_provider_for_external_user(raw)
    firm_name = extract_provider_name(raw)
    provider = Provider.find_by(name: firm_name)
    return provider if provider

    find_or_create_provider_from_supplier_numbers(raw, firm_name)
  end

  def find_or_create_provider_from_supplier_numbers(raw, firm_name)
    raise ArgumentError, "No provider found for FIRM_NAME: #{firm_name}" unless auto_create_providers_from_silas?

    agfs_numbers, lgfs_numbers = separate_agfs_and_lgfs_supplier_numbers(raw)
    ensure_no_duplicate_agfs_supplier_numbers!(agfs_numbers)

    find_provider_by_lgfs_supplier_numbers(lgfs_numbers) || create_provider_with_supplier_numbers(raw, lgfs_numbers)
  end

  def ensure_no_duplicate_agfs_supplier_numbers!(agfs_numbers)
    duplicate_agfs_supplier_number = agfs_numbers.find do |supplier_number|
      ExternalUser.exists?([SUPPLIER_NUMBER_CASE_INSENSITIVE_WHERE, supplier_number])
    end
    return unless duplicate_agfs_supplier_number

    raise ArgumentError,
          "AGFS supplier number #{duplicate_agfs_supplier_number} already registered. User may have registered another account in CCCD"
  end

  def find_provider_by_lgfs_supplier_numbers(lgfs_numbers)
    matching_supplier_number = lgfs_numbers.find do |supplier_number|
      SupplierNumber.exists?([SUPPLIER_NUMBER_CASE_INSENSITIVE_WHERE, supplier_number])
    end
    return unless matching_supplier_number

    SupplierNumber.find_by!([SUPPLIER_NUMBER_CASE_INSENSITIVE_WHERE, matching_supplier_number]).provider
  end

  def create_provider_with_supplier_numbers(raw, lgfs_supplier_numbers)
    supplier_numbers = lgfs_supplier_numbers.map { |number| SupplierNumber.new(supplier_number: number) }

    # SiLAS does not currently identify provider type, roles or VAT registration status.
    Provider.create!(
      name: extract_provider_name(raw),
      provider_type: 'firm',
      roles: ['lgfs'],
      vat_registered: true,
      firm_agfs_supplier_number: nil,
      lgfs_supplier_numbers: supplier_numbers
    )
  end

  def extract_external_user_roles(raw, provider)
    role_mapping = Silas::Roles.new(raw)
    raise ArgumentError, 'Missing LAA_ROLES in auth payload' if role_mapping.empty?

    mapped = role_mapping.external_user_roles
    raise ArgumentError, 'No valid external user roles found in LAA_ROLES' if mapped.empty?

    roles = provider.available_external_user_roles & mapped
    raise ArgumentError, 'No valid external user roles found in LAA_ROLES' if roles.empty?

    roles
  end

  def extract_provider_name(raw)
    name = raw['FIRM_NAME'].to_s.strip
    raise ArgumentError, 'Missing FIRM_NAME in auth payload' if name.empty?

    name
  end
end
