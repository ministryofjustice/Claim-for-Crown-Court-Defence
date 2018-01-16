class InjectionErrorSummarySection < SitePrism::Section
  element :header, '#error-summary-heading'
  element :dimiss_button, 'button.button-secondary'
  sections :injection_errors, '.error-summary-list > li' do
    element :link, 'a'
  end

  def injection_error_messages
    injection_errors.map { |error| error.link.text }
  end
end
