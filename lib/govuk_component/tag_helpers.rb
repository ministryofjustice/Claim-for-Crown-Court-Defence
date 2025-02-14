# frozen_string_literal: true

module GovukComponent
  module TagHelpers
    include SharedHelpers
    def govuk_tag(body = nil, color = nil, **tag_options)
      tag_options = prepend_classes('govuk-tag--' + color, tag_options) if color.present?
      tag_options = prepend_classes('govuk-tag', tag_options)

      tag.strong(body, **tag_options)
    end

    def govuk_tag_active_user?(user)
      user.active? && user.enabled? ? govuk_tag('Active', 'green') : govuk_tag('Inactive', 'red')
    end
  end
end
