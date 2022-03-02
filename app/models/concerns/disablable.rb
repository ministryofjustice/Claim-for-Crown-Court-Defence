# frozen_string_literal: true

# Include this module to provide enabled/disabled functionality to your ActiveRecord model.
# The model must have an attribute disabled_at which defaults to nil.
#
module Disablable
  extend ActiveSupport::Concern

  included do
    scope :disabled, -> { where.not(disabled_at: nil) }
    scope :enabled, -> { where(disabled_at: nil) }

    def disable
      transaction do
        update(disabled_at: Time.zone.now)
      end
    end

    def enable
      transaction do
        update(disabled_at: nil)
      end
    end

    def enabled?
      disabled_at.nil?
    end

    def disabled?
      !enabled?
    end
  end
end
