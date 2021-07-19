# config.active_support.hash_digest_class allows configuring the digest class
# to use to generate non-sensitive digests, such as the ETag header.
Rails.application.config.active_support.hash_digest_class = OpenSSL::Digest::SHA1

# config.action_controller.default_protect_from_forgery determines whether
# forgery protection is added on ActionController::Base.
Rails.application.config.action_controller.default_protect_from_forgery = true

# config.action_view.form_with_generates_ids determines whether form_with
# generates ids on inputs.
Rails.application.config.action_view.form_with_generates_ids = true

# config.active_record.cache_versioning indicates whether to use a stable
# #cache_key method that is accompanied by a changing version in the
# #cache_version method.
#
# NOTE: this setting is not taking effect since it appears
# that govuk_notify_rails is causing early rails loading and
# causing it to be "lost".
# see https://github.com/rails/rails/issues/39855#issuecomment-659670294
Rails.application.config.active_record.cache_versioning = true
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# suggested by this issue comment https://github.com/rails/rails/issues/37030#issuecomment-524511912
ActiveRecord::Base.cache_versioning = true

# config.action_dispatch.use_authenticated_cookie_encryption controls whether
# signed and encrypted cookies use the AES-256-GCM cipher or the older
# AES-256-CBC cipher. It defaults to true.
Rails.application.config.action_dispatch.use_authenticated_cookie_encryption = true

# config.active_support.use_authenticated_message_encryption specifies whether
# to use AES-256-GCM authenticated encryption as the default cipher for
# encrypting messages instead of AES-256-CBC.
Rails.application.config.active_support.use_authenticated_message_encryption = true
