# frozen_string_literal: true

module GovukComponent
  module TagHelpers
    def govuk_tag(body = nil, color = nil, **tag_options)
      tag_options = prepend_classes('govuk-tag--' + color, tag_options) if color.present?
      tag_options = prepend_classes('govuk-tag', tag_options)

      tag.strong(body, **tag_options)
    end
  end
end
