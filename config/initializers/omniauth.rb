require 'omniauth/openid_connect'
require Rails.root.join('lib/omniauth/strategies/entra_mock')

OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true

Rails.application.config.middleware.use OmniAuth::Builder do
	if Rails.env.development? || Rails.env.test?
		provider :entra_mock, {}
	end

	provider :openid_connect,
					 name: :entra_id,
					 scope: %w[openid email profile],
					 prompt: :select_account,
					 response_type: :code,
					 send_nonce: true,
					 pkce: true,
					 discovery: true,
					 issuer: "https://login.microsoftonline.com/#{ENV.fetch('ENTRA_ID_TENANT_ID', 'common')}/v2.0",
					 client_options: {
						 identifier: ENV.fetch('ENTRA_ID_CLIENT_ID', nil),
						 secret: ENV.fetch('ENTRA_ID_CLIENT_SECRET', nil),
						 redirect_uri: ENV.fetch('ENTRA_ID_REDIRECT_URI', 'http://localhost:3000/users/auth/entra_id/callback')
					 }
end
