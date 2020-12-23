# frozen_string_literal: true

module GovukComponent
  module WarningTextHelpers
    def govuk_warning_text(body = nil, assistive_text = t('common.warning'), **tag_options)
      tag_options = prepend_classes('govuk-warning-text', tag_options)

      text__assistive = tag.span(assistive_text, class: 'govuk-warning-text__assistive')
      content = sanitize(body)
      tag.div(tag_options) do
        concat tag.span('!', class: 'govuk-warning-text__icon', 'aria-hidden': true)
        concat tag.strong(text__assistive + content, class: 'govuk-warning-text__text')
      end
    end
  end
end
