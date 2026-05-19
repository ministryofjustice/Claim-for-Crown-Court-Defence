require Rails.root.join('lib/omniauth/strategies/entra_mock')

OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
