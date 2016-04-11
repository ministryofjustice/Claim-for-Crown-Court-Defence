class ConfirmationPage < SitePrism::Page
  set_url "/external_users/claims/{id}/confirmation"

  element :view_your_claims, "div.button-holder > a:nth-of-type(2)"
end
