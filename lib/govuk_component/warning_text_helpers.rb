# frozen_string_literal: true

module GovukComponent
  module WarningTextHelpers
    def govuk_warning_text(body = nil, assistive_text = t('common.warning'), **tag_options, &)
      tag_options = prepend_classes('govuk-warning-text', tag_options)

      text__assistive = tag.span(assistive_text, class: 'govuk-visually-hidden')
      content = sanitize(body)
      tag.div(**tag_options) do
        concat tag.span('!', class: 'govuk-warning-text__icon', 'aria-hidden': true)
        concat tag.strong(text__assistive + content, class: 'govuk-warning-text__text')
        govuk_warning_text_description(&)
      end
    end

    def govuk_warning_text_description(&block)
      return unless block

      concat tag.div(
        capture(&block),
        class: 'govuk-warning-text__text govuk-!-font-weight-regular govuk-!-margin-top-4'
      )
    end
  end
end
