# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 6.0 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# see https://guides.rubyonrails.org/autoloading_and_reloading_constants.html
# There is a separate ticket to handle upgrade to zeitwork, we should stick
# to :classic for the time being.
# Rails.application.config.autoloader = :zeitwerk

# Determines whether forms are generated with a hidden tag that forces older versions of Internet Explorer to submit forms encoded in UTF-8.
Rails.application.config.action_view.default_enforce_utf8 = false

# Embed purpose and expiry metadata inside signed and encrypted
# cookies for increased security.
#
# This option is not backwards compatible with earlier Rails versions.
# It's best enabled when your entire app is migrated and stable on 6.0.
Rails.application.config.action_dispatch.use_cookies_with_metadata = true

# Send Active Storage analysis and purge jobs to dedicated queues.
# DO NOT ENABLE: since we are on 6.1 and these options are both changed
# to default to nil (which equates to using the default queue)
# we do not need to enable these here.
#
# Rails.application.config.active_storage.queues.analysis = :active_storage_analysis
# Rails.application.config.active_storage.queues.purge = :active_storage_purge

# When assigning to a collection of attachments declared via `has_many_attached`, replace existing
# attachments instead of appending. Use #attach to add new attachments without replacing existing ones.
# Rails.application.config.active_storage.replace_on_assign_to_many = true

# Use ActionMailer::MailDeliveryJob for sending parameterized and normal mail.
#
# The default delivery jobs (ActionMailer::Parameterized::DeliveryJob, ActionMailer::DeliveryJob),
# will be removed in Rails 6.1. This setting is not backwards compatible with earlier Rails versions.
# If you send mail in the background, job workers need to have a copy of
# MailDeliveryJob to ensure all delivery jobs are processed properly.
# Make sure your entire app is migrated and stable on 6.0 before using this setting.
# Rails.application.config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"

# Enable the same cache key to be reused when the object being cached of type
# `ActiveRecord::Relation` changes by moving the volatile information (max updated at and count)
# of the relation's cache key into the cache version to support recycling cache key.
# Rails.application.config.active_record.collection_cache_versioning = true
