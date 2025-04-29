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

    initializer 'govuk_component.notification_banner_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::NotificationBannerHelpers }
      end
    end

    initializer 'govuk_component.panel_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::PanelHelpers }
      end
    end

    initializer 'govuk_component.phase_banner_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::PhaseBannerHelpers }
      end
    end

    initializer 'govuk_component.summary_list_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::SummaryListHelpers }
      end
    end

    initializer 'govuk_component.tag_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::TagHelpers }
      end
    end

    initializer 'govuk_component.warning_text_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::WarningTextHelpers }
      end
    end

    initializer 'govuk_component.summary_card_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GovukComponent::SummaryCardHelpers }
      end
    end
  end
end
