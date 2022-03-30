# frozen_string_literal: true

# Use this module to delegate enabled/disabled functionality to another class
#
# Extend a class with module and then Include the delegating class method, supplying
# the name of the class that it should delegate to.
#
# The class delegated to must `Include Disablable` module
#
# e.g.
# class Account
#  include disablable
# end
#
# class Person
#   extend DisablableDelegator
#   include delegate_disablable_to(:account)
# end
#
module DisablableDelegator
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def delegate_disablable_to(class_name)
    Module.new do
      extend ActiveSupport::Concern

      included do
        delegate :disabled_at=,
                 :disabled_at,
                 :disable,
                 :disabled?,
                 :enable,
                 :enabled?,
                 to: class_name

        scope :disabled, -> { joins(class_name).merge(class_name.to_s.camelize.constantize.disabled) }
        scope :enabled, -> { joins(class_name).merge(class_name.to_s.camelize.constantize.enabled) }
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
