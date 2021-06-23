class ProviderSearchPage < BasePage
  set_url '/provider_management/external_users/find'

  element :email, 'input#external-user-email-field'

  element :search, 'button.govuk-button', text: 'Search'
end
