# frozen_string_literal: true

# Component Reference: https://design-system.service.gov.uk/components/summary-list/

module GovukComponent
  module SummaryListHelpers
    def govuk_summary_list(tag_options = {}, &)
      tag_options = prepend_classes('govuk-summary-list', tag_options)

      tag.dl(capture_output(&), **tag_options)
    end

    def govuk_summary_list_no_border(tag_options = {}, &)
      tag_options = prepend_classes('govuk-summary-list govuk-summary-list--no-border', tag_options)

      tag.dl(capture_output(&), **tag_options)
    end

    def govuk_summary_list_row(tag_options = {}, &)
      tag_options = prepend_classes('govuk-summary-list__row', tag_options)

      tag.div(capture_output(&), **tag_options)
    end

    def govuk_summary_list_key(tag_options = {}, &)
      tag_options = prepend_classes('govuk-summary-list__key', tag_options)

      tag.dt(capture_output(&), **tag_options)
    end

    def govuk_summary_list_value(tag_options = {}, &)
      tag_options = prepend_classes('govuk-summary-list__value', tag_options)

      tag.dd(capture_output(&), **tag_options)
    end

    def govuk_summary_list_action(tag_options = {}, &)
      tag_options = prepend_classes('govuk-summary-list__actions', tag_options)

      tag.dd(capture_output(&), **tag_options)
    end

    # rubocop:disable Metrics/ParameterLists
    def govuk_summary_list_row_collection(list_key = nil, list_value = nil, list_action = nil, tag_options = {}, &block)
      value = block ? capture_output(&block) : list_value

      govuk_summary_list_row(**tag_options) do
        concat(govuk_summary_list_key { list_key })
        concat(govuk_summary_list_value { value })
        concat(govuk_summary_list_action { list_action }) if list_action.present?
      end
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
