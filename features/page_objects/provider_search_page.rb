class ProviderSearchPage < BasePage
  set_url "/provider_management/external_users/find"

  element :email, "input.email"

  element :search, "button.govuk-button"
end
