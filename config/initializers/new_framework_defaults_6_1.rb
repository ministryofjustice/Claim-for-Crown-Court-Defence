# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 6.1 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Support for inversing belongs_to -> has_many Active Record associations.
Rails.application.config.active_record.has_many_inversing = true
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# suggested by this issue comment https://github.com/rails/rails/issues/37030#issuecomment-524511912
ActiveRecord::Base.has_many_inversing = true

# Track Active Storage variants in the database.
# Rails.application.config.active_storage.track_variants = true

# Apply random variation to the delay when retrying failed jobs.
Rails.application.config.active_job.retry_jitter = 0.15
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# suggested by this issue comment https://github.com/rails/rails/issues/37030#issuecomment-524511912
ActiveJob::Base.retry_jitter = 0.15

# Stop executing `after_enqueue`/`after_perform` callbacks if
# `before_enqueue`/`before_perform` respectively halts with `throw :abort`.
Rails.application.config.active_job.skip_after_callbacks_if_terminated = true
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# suggested by this issue comment https://github.com/rails/rails/issues/37030#issuecomment-524511912
ActiveJob::Base.skip_after_callbacks_if_terminated = true

# Specify cookies SameSite protection level: either :none, :lax, or :strict.
#
# This change is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 6.1.
Rails.application.config.action_dispatch.cookies_same_site_protection = :lax

# Generate CSRF tokens that are encoded in URL-safe Base64.
#
# This change is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 6.1.
Rails.application.config.action_controller.urlsafe_csrf_tokens = true

# Specify whether `ActiveSupport::TimeZone.utc_to_local` returns a time with an
# UTC offset or a UTC time.
ActiveSupport.utc_to_local_returns_utc_offset_times = true

# Change the default HTTP status code to `308` when redirecting non-GET/HEAD
# requests to HTTPS in `ActionDispatch::SSL` middleware.
Rails.application.config.action_dispatch.ssl_default_redirect_status = 308

# Use new connection handling API. For most applications this won't have any
# effect. For applications using multiple databases, this new API provides
# support for granular connection swapping.
Rails.application.config.active_record.legacy_connection_handling = false
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# suggested by this issue comment https://github.com/rails/rails/issues/37030#issuecomment-524511912
ActiveRecord::Base.legacy_connection_handling = false

# Make `form_with` generate non-remote forms by default.
Rails.application.config.action_view.form_with_generates_remote_forms = false

# Adopt separate queue name so we can control/lower priority
# this is a change from default for rails 6.1 which is nil (i.e. default queue)
Rails.application.config.active_storage.queues.analysis = :active_storage_analysis

# Adopt separate queue name so we can control/lower priority
# this is a change from default for rails 6.1 which is nil (i.e. default queue)
Rails.application.config.active_storage.queues.purge = :active_storage_purge

# Set the default queue name for the incineration job to the queue adapter default.
Rails.application.config.action_mailbox.queues.incineration = nil

# Set the default queue name for the routing job to the queue adapter default.
Rails.application.config.action_mailbox.queues.routing = nil

# Set the default queue name for the mail deliver job to the queue adapter default.
Rails.application.config.action_mailer.deliver_later_queue_name = :mailers
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# suggested by this issue comment https://github.com/rails/rails/issues/37030#issuecomment-524511912
ActionMailer::Base.deliver_later_queue_name = :mailers

# Generate a `Link` header that gives a hint to modern browsers about
# preloading assets when using `javascript_include_tag` and `stylesheet_link_tag`.
Rails.application.config.action_view.preload_links_header = true
