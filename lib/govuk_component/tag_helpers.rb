# frozen_string_literal: true

module GovukComponent
  module TagHelpers
    def govuk_tag(body = nil, color = nil, **tag_options)
      tag_options = prepend_classes('govuk-tag--' + color, tag_options) if color.present?
      tag_options = prepend_classes('govuk-tag', tag_options)

      tag.strong(body, **tag_options)
    end

    def govuk_tag_active_user?(user)
      status = user.active? && user.enabled? ? 'Active' : 'Inactive'
      tag_class = status == 'Active' ? 'govuk-tag--green' : 'govuk-tag--red'

      content_tag(:strong, status, class: "govuk-tag #{tag_class}")
    end
  end
end
