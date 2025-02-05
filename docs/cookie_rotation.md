## Session cookie rotation

### About

The session cookie, amongst others, is encrypted based on the value of the `secret_key_base` secret. If this
secret changes then all existing session cookies become invalid and users would be forced to login again or
encounter errors. To rotate the `secret_key_base` secret, for security reasons, while mitigating the impact
on users you can follow this guide.

### Guide

Encrypted cookie rotation is performed by the `config/initializers/cookie_rotation.rb` initializer
but it will only take action if there is an `old_secret_key_base` secret in `config/secrets.yml`.

Thr cookie rotator used by this guide has been removed from `config/initializers/cookie_rotation.rb` and copied [below for reference](#example).

To rotate the `secret_key_base` without inconveniencing users you must:

1. add an old_secret_key_base to `config/secrets.yml`
   and assign its value to that of the current secret
   you wish to rotate.

2. generate a new secret at a terminal rooted in the
   (or any rails) repo using `rails secret` and assign
   the existing `secret_key_base`'s value to be that
   of the new secret
   example:
   ```
   # config/secrets.yml
   development:
     old_secret_key_base: my-current-local-secret-key-base-secret
     secret_key_base: my-new-local-secret-key-base-secret
   ....
   production:
     old_secret_key_base: <%= ENV["OLD_SECRET_KEY_BASE"] %>
     secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
   ```

3. For production, as in the above example, you will need to
   add an OLD_SECRET_KEY_BASE env variable to each namespace/host,
   add the current secret to that and modify the existing
   SECRET_KEY_BASE to hold the new secret.

   Note: secret env vars are kept in Kubernetes Secrets on the cluster
   They can be viewed by running `kubectl -n <namespace> get secrets cccd-env-vars -o json`.

4. Deploy the application, manually [updating](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/add-secrets-to-deployment.html#adding-a-secret-to-an-application) the Secrets in the cluster first. 

5. Leave the rotation in place for x, where x is however
   long (days?!) we think it will take the majority of
   users to have visited the site and have their cookies rotated.

6. After x amount of time you should then delete the
   `old_secret_key_base` secret entry from `config/secrets.yml`
   and any matching `OLD_SECRET_KEY_BASE` env variable. You
   should do this at time of low traffic to minimise
   inconvenience for users.

### How it works:
  The process above will add a fallback encryptor that uses
  the `old_secret_key_base` secret to verify session cookies
  are valid if the "primary" encryptor (that uses `secret_key_base`)
  determines it to be invalid.

  Nonetheless, a new session cookie will be generated using
  the new `secret_key_base` secret.

  Anyone visiting the site using an old session cookie
  will not be considered invalid AND will transparently generate
  themselves a new session cookie using the new secret.
  Once the old key is deleted those who have visited the site in
  the interim will already have a valid session cookie in any event
  and those who do not will be logged out.

  A futher mitigation of the impact would therefore be to do
  the deploy that deletes the old key at a time of low traffic
  to avoid inconveniencing as few people as possible. The inconvenience
  for these individuals would be, at best, a redirect to login, but could
  possibly cause form input loss if the input is not yet saved, and in
  some cases a 500 may occur. This last might typically happen if they
  are on a form page with validation errors displaying and they
  attempt to resubmit with more validation errors.

### Example

The cookie rotator that was used for updating the secret key base is copied here for future reference.

```
# config/initializers/cookie_rotator.rb
#
# It will only take action if there is an
# `old_secret_key_base` secret in `config/secrets.yml`.
#
# NOTE: any changes to rails `action_dispatch` encryption config will
# impact this functionality, rendering it in need of revisiting - manual
# testing.
#
return unless Settings.old_secret_key_base.present?

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

    old_secret_key_base = Settings.old_secret_key_base
    generator = ActiveSupport::KeyGenerator.new(old_secret_key_base, iterations: 1000)
    len = ActiveSupport::MessageEncryptor.key_len(cipher)
    secret = generator.generate_key(salt, len)
    sign_secret = generator.generate_key(signed_salt)

    cookies.rotate :encrypted, secret, sign_secret
  end
end
```