Feature: API new claim

  Background: the API creation of a claim has a different validation from claim creation in the web app

  Scenario: New claim via API is saved as draft, again, in web app without errors
    Given I am a signed in advocate
      And I create a draft claim marked as from API
      And I am on the claim edit page
      And show me the page
     When I save to drafts
     Then I should not see errors
