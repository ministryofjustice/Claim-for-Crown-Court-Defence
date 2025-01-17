# frozen_string_literal: true

module GovukComponent
  module DetailHelpers
    def govuk_detail(summary_text = nil, tag_options = {}, &)
      tag_options = prepend_classes('govuk-details', tag_options)
      tag_options[:data] = { module: 'govuk-details' }

      summary = tag.span(summary_text, class: 'govuk-details__summary-text')
      content = capture(&)
      tag.details(**tag_options) do
        concat tag.summary(summary, class: 'govuk-details__summary')
        concat tag.div(content, class: 'govuk-details__text')
      end
    end
  end
end
