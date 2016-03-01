@advocate @api-sandbox
Feature: API new claim

  Background: the API creation of a draft claim applies validation, unlike claim creation in the web app, but subsequent saving as draft in the web app for an API claim should not.

  # failing because validation on total is applied to draft claims before fees/expenses are created
  Scenario: New claim via API is saved as draft, again, in web app without errors
    Given I am a signed in advocate
      And I create a draft claim marked as from API
      And I am on the claim edit page
     When I save to drafts
     Then I should not see errors
