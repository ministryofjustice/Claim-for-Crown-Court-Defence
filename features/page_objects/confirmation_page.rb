class ConfirmationPage < BasePage
  set_url "/external_users/claims/{id}/confirmation"

  element :view_your_claims, 'a.govuk-button--secondary'
end
