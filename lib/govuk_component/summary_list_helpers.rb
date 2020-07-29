# frozen_string_literal: true

module GovukComponent
  module SummaryListHelpers
    def govuk_summary_list(**tag_options, &block)
      tag_options = prepend_classes('govuk-summary-list', tag_options)
      list_row = capture(&block)
      tag.dl(list_row, tag_options)
    end

    def govuk_summary_list_row(list_key = nil, list_actions = nil, &block)
      list_value = capture(&block)
      tag.div(class: 'govuk-summary-list__row') do
        concat tag.dt(list_key, class: 'govuk-summary-list__key')
        concat tag.dd(list_value, class: 'govuk-summary-list__value')
        concat tag.dd(list_actions, class: 'govuk-summary-list__actions') if list_actions.present?
      end
    end
  end
end
