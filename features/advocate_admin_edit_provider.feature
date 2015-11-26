@wip

Feature: Provider Administration
  Background:
    As an advocate admin I want to be able to manage the provider I am an admin for.

Scenario: Generate a new API key for provider
    Given I am a signed in advocate admin
     When I visit the Manage provider page
      And I click "Generate new key"
     Then I should be redirected to the Manage provider page
      And I should see a new api key

Scenario: Edit supplier number
    Given I am a signed in advocate admin
     When I visit the Edit provider page
      And I fill in supplier number with "C9999"
      And I click "Save"
     Then I should be redirected to the Manage provider page
      And I should see a supplier of "C9999"
