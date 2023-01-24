# See `docs/cookie_rotation.md` for details.
#
# This initializer can be kept for future
# rotation or it can be deleted.
#
# It will only take action if there is an
# `old_secret_key_base` secret in `config/secrets.yml`.
#
# NOTE: any changes to rails `action_dispatch` encryption config will
# impact this functionality, rendering it in need of revisiting - manual
# testing.
#
return unless Rails.application.secrets.old_secret_key_base.present?

Rails.application.configure do
  # Not technically necessary, as this is the current default,
  # but it is to line up with the config below.
  config.action_dispatch.use_authenticated_cookie_encryption = true

  # Originally from:
  # https://www.gitmemory.com/issue/rails/rails/39964/668147345
  # This page has disappeared but it may have been a reference to:
  # https://github.com/rails/rails/issues/39964
  # The official documentation for rotating the cookies, with respect to
  # upgrading to Rails 7:
  # https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#key-generator-digest-class-changing-to-use-sha256
  # --------------------------------------------------------------------------------
  config.action_dispatch.cookies_rotations.tap do |cookies|
    salt = config.action_dispatch.authenticated_encrypted_cookie_salt
    signed_salt = config.action_dispatch.encrypted_signed_cookie_salt
    cipher = config.action_dispatch.encrypted_cookie_cipher || 'aes-256-gcm'

    old_secret_key_base = Rails.application.secrets.old_secret_key_base
    generator = ActiveSupport::KeyGenerator.new(old_secret_key_base, iterations: 1000)
    len = ActiveSupport::MessageEncryptor.key_len(cipher)
    secret = generator.generate_key(salt, len)
    sign_secret = generator.generate_key(signed_salt)

    cookies.rotate :encrypted, secret, sign_secret
  end
end
