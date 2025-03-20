# frozen_string_literal: true

# Component Reference: https://design-system.service.gov.uk/components/summary-list/

module GovukComponent
  module SummaryCardHelpers
    def govuk_summary_card(title = '', content = '')
      tag.div(class: 'govuk-summary-card') do
        concat(tag.div(class: 'govuk-summary-card__title-wrapper') do
          content_tag(:h2, title, class: 'govuk-summary-card__title')
        end)
        concat(content_tag(:div, format_multiline(content), class: 'govuk-summary-card__content'))
      end
    end
  end
end
