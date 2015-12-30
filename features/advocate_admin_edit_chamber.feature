@wip

Feature: Chamber Administration
  Background:
    As an advocate admin I want to be able to manage the chamber details I am an admin for.

Scenario: Generate a new API key for chamber
    Given I am a signed in advocate admin
     When I visit the Manage chamber page
      And I click "Generate new key"
     Then I should be redirected to the Manage chamber page
      And I should see a new api key

Scenario: Edit supplier number
    Given I am a signed in advocate admin
     When I visit the Edit chamber page
      And I fill in supplier number with "C9999"
      And I click "Save"
     Then I should be redirected to the Manage chamber page
      And I should see a supplier of "C9999"
