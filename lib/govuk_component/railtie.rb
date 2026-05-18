# frozen_string_literal: true

require 'rails'

module GovukComponent
  class Railtie < Rails::Railtie
    initializer 'govuk_component.shared_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::SharedHelpers }
      end
    end
  end
end
