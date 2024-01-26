# frozen_string_literal: true

require 'rails'

module GOVUKComponent
  class Railtie < Rails::Railtie
    initializer 'govuk_component.shared_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::SharedHelpers }
      end
    end

    initializer 'govuk_component.button_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::ButtonHelpers }
      end
    end

    initializer 'govuk_component.detail_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::DetailHelpers }
      end
    end

    initializer 'govuk_component.inset_text_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::InsetTextHelpers }
      end
    end

    initializer 'govuk_component.link_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::LinkHelpers }
      end
    end

    initializer 'govuk_component.notification_banner_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::NotificationBannerHelpers }
      end
    end

    initializer 'govuk_component.panel_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::PanelHelpers }
      end
    end

    initializer 'govuk_component.phase_banner_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::PhaseBannerHelpers }
      end
    end

    initializer 'govuk_component.summary_list_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::SummaryListHelpers }
      end
    end

    initializer 'govuk_component.table_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::TableHelpers }
      end
    end

    initializer 'govuk_component.tag_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::TagHelpers }
      end
    end

    initializer 'govuk_component.warning_text_helpers' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include GOVUKComponent::WarningTextHelpers }
      end
    end
  end
end
