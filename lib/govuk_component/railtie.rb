# frozen_string_literal: true

require 'rails'

module GOVUKComponent
  class Railtie < Rails::Railtie
    initializer 'govuk_component.shared_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::SharedHelpers }
    end

    initializer 'govuk_component.button_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::ButtonHelpers }
    end

    initializer 'govuk_component.detail_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::DetailHelpers }
    end

    initializer 'govuk_component.inset_text_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::InsetTextHelpers }
    end

    initializer 'govuk_component.link_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::LinkHelpers }
    end

    initializer 'govuk_component.notification_banner_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::NotificationBannerHelpers }
    end

    initializer 'govuk_component.panel_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::PanelHelpers }
    end

    initializer 'govuk_component.phase_banner_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::PhaseBannerHelpers }
    end

    initializer 'govuk_component.summary_list_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::SummaryListHelpers }
    end

    initializer 'govuk_component.table_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::TableHelpers }
    end

    initializer 'govuk_component.tag_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::TagHelpers }
    end

    initializer 'govuk_component.warning_text_helpers' do
      ActiveSupport.on_load(:action_view) { include GOVUKComponent::WarningTextHelpers }
    end
  end
end
