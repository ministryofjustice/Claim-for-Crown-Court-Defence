# frozen_string_literal: true

# rubocop:disable Naming/PredicateName
module CapybaraExtensions
  module GOVUKComponent
    module Matchers
      def has_govuk_section_title?(**options)
        has_selector?('h2.govuk-heading-l', **options)
      end

      def has_govuk_page_title?(options = {})
        has_selector?('h1.govuk-heading-xl', **options)
      end

      def has_govuk_flash?(options = {})
        has_selector?('.govuk-error-summary', **options)
      end

      def has_govuk_warning?(text = nil)
        [
          has_selector?('.govuk-warning-text strong.govuk-warning-text__text', text: text),
          has_selector?('.govuk-warning-text span.govuk-warning-text__icon', text: '!'),
          has_selector?('.govuk-warning-text span.govuk-warning-text__assistive', text: 'Warning')
        ].all?
      end

      def has_govuk_error_summary?(error_text = nil, options = {})
        summary = find('.govuk-error-summary[role="alert"]')
        [
          summary.has_selector?('#error-summary-title', text: 'There is a problem'),
          summary.has_link?(error_text, options)
        ].all?
      end

      def has_govuk_error_fieldset?(locator, text: nil, id: nil)
        fieldset = find('.govuk-fieldset__legend', text: locator).find(:xpath, '..')

        [
          fieldset.find('.govuk-error-message').has_text?(text),
          fieldset.first('label')[:for].eql?(id || fieldset.first('label')[:for])
        ].all?
      end

      def has_govuk_error_field?(locator, text: nil, id: nil)
        field = find_field(locator)

        [
          field.sibling('.govuk-error-message').has_text?(text),
          field[:id].eql?(id || field[:id])
        ].all?
      end

      def has_govuk_detail_summary?(text, options = {})
        has_selector?(detail_summary_selector, **options.merge(text: text))
      end

      def has_no_govuk_detail_summary?(text, options = {})
        has_no_selector?(detail_summary_selector, **options.merge(text: text))
      end

      def click_govuk_detail_summary(text, options = {})
        detail_summary = find(detail_summary_selector, **options.merge(text: text))
        detail_summary.click
      end

      def detail_summary_selector
        'details.govuk-details summary.govuk-details__summary span.govuk-details__summary-text'
      end
    end
  end
end
# rubocop:enable Naming/PredicateName
