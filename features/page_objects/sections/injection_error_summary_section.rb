class InjectionErrorSummarySection < SitePrism::Section
  element :header, '.govuk-error-summary__title'
  element :dismiss_link, '.cb-dismiss-link'
  sections :injection_errors, '.govuk-error-summary__list > li' do
    element :link, 'a'
  end

  def injection_error_messages
    injection_errors.map { |error| error.link.text }
  end
end
