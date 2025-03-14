# frozen_string_literal: true

require 'rails'

module MojComponent
  class Railtie < Rails::Railtie
    initializer 'moj_component.sub_navigation_helper' do
      config.after_initialize do
        ActiveSupport.on_load(:action_view) { include MojComponent::SubNavigationHelpers }
      end
    end
  end
end
