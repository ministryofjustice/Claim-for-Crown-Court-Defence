# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.

# Enable per-form CSRF tokens. Previous versions had false.
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Previous versions had false.
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# Previous versions had false.
ActiveSupport.to_time_preserves_timezone = true

# Require `belongs_to` associations by default. Previous versions had false.
# NOTE: this setting is not taking effect since it appears
# that govuk_notify_rails is causing early rails loading and
# causing it to be "lost".
Rails.application.config.active_record.belongs_to_required_by_default = true

# see https://github.com/rails/rails/issues/39855#issuecomment-659670294
# This is a workaround for issue https://github.com/rails/rails/issues/39855#issuecomment-659670294
# and this activerecord specific issue https://github.com/rails/rails/issues/27844
ActiveRecord::Base.belongs_to_required_by_default = true
