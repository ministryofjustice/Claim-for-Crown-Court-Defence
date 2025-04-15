# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

GOOGLE_ANALYTICS_DOMAIN = "https://*.google-analytics.com".freeze
GOOGLE_TAG_MANAGER_DOMAIN = "https://*.googletagmanager.com".freeze

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.connect_src :self, :https, GOOGLE_ANALYTICS_DOMAIN, GOOGLE_TAG_MANAGER_DOMAIN, "https://*.analytics.google.com"
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, GOOGLE_ANALYTICS_DOMAIN, GOOGLE_TAG_MANAGER_DOMAIN
    policy.object_src  :none
    # TODO: unsafe_inline should be removed but this cannot be done until some Javascript is refactored.
    policy.script_src  :self, "'wasm-unsafe-eval'", :unsafe_inline, :https, GOOGLE_TAG_MANAGER_DOMAIN
    policy.style_src   :self, :unsafe_inline, :https
    # Specify URI for violation reports
    policy.report_uri "/csp_report"
  end

  # Generate session nonces for permitted importmap and inline scripts
  # TODO: Enable these options. This can only be done when unsafe_inline is removed above.
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_directives = %w(script-src)

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true
end
