class CertificationPage < BasePage
  set_url "/external_users/claims/{id}/certification/new"

  element :attended_main_hearing, "label.govuk-radios__label", text: "I attended the main hearing (1st day of trial)"
  element :certify_and_submit_claim, "input[value='Certify and submit claim']"
end
