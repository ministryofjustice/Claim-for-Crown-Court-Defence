# frozen_string_literal: true

require 'rails'

module GovukComponent
  class Railtie < Rails::Railtie
    initializer 'govuk_component.panel_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::PanelHelpers }
    end
  end
end
