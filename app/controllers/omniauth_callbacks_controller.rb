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

  def find_case_worker(info, _raw)
    email = info.email
    user = User.find_by(email: email)
    return [nil, missing_user_message(email)] if user.nil?
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

  def persona_mismatch_message(email, actual, expected)
    return nil unless Rails.env.development?

    "User #{email} is #{actual}, expected #{expected}."
  end
end
