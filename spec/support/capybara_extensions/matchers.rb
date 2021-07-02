# frozen_string_literal: true

# Extensions to capybara can be written here
# and they will be mixed into existing
# helpers/matchers by the `features/support/capybara.rb`
#
# Idea comes from:
# https://github.com/DavyJonesLocker/capybara-extensions
#

require_relative 'govuk_component_matchers'

module CapybaraExtensions
  module Matchers
    include GOVUKComponent::Matchers
  end
end
