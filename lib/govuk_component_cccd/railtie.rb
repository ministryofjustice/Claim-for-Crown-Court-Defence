# frozen_string_literal: true

require 'rails'

module GovukComponentCccd
  class Railtie < Rails::Railtie
    initializer 'govuk_component_cccd.shared_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::SharedHelpers }
    end

    initializer 'govuk_component_cccd.button_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::ButtonHelpers }
    end

    initializer 'govuk_component_cccd.detail_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::DetailHelpers }
    end

    initializer 'govuk_component_cccd.inset_text_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::InsetTextHelpers }
    end

    initializer 'govuk_component_cccd.link_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::LinkHelpers }
    end

    initializer 'govuk_component_cccd.notification_banner_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::NotificationBannerHelpers }
    end

    initializer 'govuk_component_cccd.panel_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::PanelHelpers }
    end

    initializer 'govuk_component_cccd.phase_banner_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::PhaseBannerHelpers }
    end

    initializer 'govuk_component_cccd.summary_list_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::SummaryListHelpers }
    end

    initializer 'govuk_component_cccd.table_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::TableHelpers }
    end

    initializer 'govuk_component_cccd.tag_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::TagHelpers }
    end

    initializer 'govuk_component_cccd.warning_text_helpers' do
      ActiveSupport.on_load(:action_view) { include GovukComponentCccd::WarningTextHelpers }
    end
  end
end
