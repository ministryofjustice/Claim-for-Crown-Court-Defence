class CertificationPage < BasePage
  set_url_matcher(/external_users\/claims\/\d+\/certification(\/new)?/)

  element :attended_main_hearing, "label.govuk-radios__label", text: "I attended the main hearing (1st day of trial)"
  element :certified_by, "input[name='certification[certified_by]']"
  section :certification_date, GovukDateSection, '#certification_date'
  element :certify_and_submit_claim, 'button.govuk-button', text: 'Certify and submit claim'
end
