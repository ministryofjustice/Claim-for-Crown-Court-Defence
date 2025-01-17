# frozen_string_literal: true

module GovukComponent
  module NotificationBannerHelpers
    def govuk_notification_banner(header = nil, content = nil, tag_options = {}, &)
      govuk_notification_banner_options(tag_options)

      header_element = tag.h2(header, class: 'govuk-notification-banner__title', id: 'govuk-notification-banner-title')

      content_element = capture_or_tag(content, &)

      tag.div(**tag_options) do
        concat tag.div(header_element, class: 'govuk-notification-banner__header')
        concat tag.div(content_element, class: 'govuk-notification-banner__content')
      end
    end

    private

    def govuk_notification_banner_options(options)
      options[:aria] = { labelledby: 'govuk-notification-banner-title' }
      options[:data] = { module: 'govuk-notification-banner' }
      options[:role] = 'alert'
      prepend_classes('govuk-notification-banner', options)
    end

    def capture_or_tag(content = nil, &block)
      if block
        capture(&block)
      else
        tag.p(content, class: 'govuk-notification-banner__heading')
      end
    end
  end
end
