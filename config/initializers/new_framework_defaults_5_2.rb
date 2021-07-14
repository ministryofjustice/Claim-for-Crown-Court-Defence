# config.active_support.hash_digest_class allows configuring the digest class
# to use to generate non-sensitive digests, such as the ETag header.
Rails.application.config.active_support.hash_digest_class = OpenSSL::Digest::SHA1

# config.action_controller.default_protect_from_forgery determines whether
# forgery protection is added on ActionController::Base.
Rails.application.config.action_controller.default_protect_from_forgery = true

# config.action_view.form_with_generates_ids determines whether form_with
# generates ids on inputs.
Rails.application.config.action_view.form_with_generates_ids = true
