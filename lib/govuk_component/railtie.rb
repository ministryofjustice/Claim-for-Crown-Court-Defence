# frozen_string_literal: true

require 'rails'

module GovukComponent
  class Railtie < Rails::Railtie
    initializer 'govuk_component.shared_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::SharedHelpers }
    end

    initializer 'govuk_component.detail_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::DetailHelpers }
    end

    initializer 'govuk_component.inset_text_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::InsetTextHelpers }
    end

    initializer 'govuk_component.link_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::LinkHelpers }
    end

    initializer 'govuk_component.panel_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::PanelHelpers }
    end

    initializer 'govuk_component.phase_banner_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::PhaseBannerHelpers }
    end

    initializer 'govuk_component.tag_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::TagHelpers }
    end

    initializer 'govuk_component.warning_text_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponent::WarningTextHelpers }
    end
  end
end
