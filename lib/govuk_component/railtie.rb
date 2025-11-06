# frozen_string_literal: true

require 'rails'

module GovukComponent
  class Railtie < Rails::Railtie
    initializer 'govuk_component.shared_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::SharedHelpers }
      end
    end

    initializer 'govuk_component.link_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::LinkHelpers }
      end
    end

    initializer 'govuk_component.phase_banner_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::PhaseBannerHelpers }
      end
    end

    initializer 'govuk_component.tag_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::TagHelpers }
      end
    end
  end
end
