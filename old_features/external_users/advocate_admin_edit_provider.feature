@advocate @admin
Feature: Provider Administration
  Background:
    As an advocate admin I want to be able to manage the provider I am an admin for.
  Given I am a signed in advocate admin

Scenario: Generate a new API key for provider
     When I visit the Manage provider page
      And I click "Generate new key"
     Then I should be redirected to the Manage provider page
      And I should see a new api key

Scenario: Edit supplier number for firm
    Given my provider is a "firm"
     When I visit the Edit provider page
      And I fill in supplier number with "C9999"
      And I click "Save"
     Then I should be redirected to the Manage provider page
      And I should see a supplier of "C9999"

Scenario: Edit supplier number for chamber
    Given my provider is a "chamber"
     When I visit the Edit provider page
     Then I should not see the supplier number field
      And I visit the Manage provider page
     Then I should not see a supplier number

Scenario: Edit VAT registration for firm
    Given my provider is a "firm"
     When I visit the Edit provider page
      And I fill in supplier number with "D9998"
      And I choose "Yes" for VAT registration
      And I click "Save"
     Then I should be redirected to the Manage provider page
      And I should see VAT registration status of "Yes"
      And I should see a supplier of "D9998"
     When I visit the Edit provider page
      And I fill in supplier number with "D9997"
      And I choose "No" for VAT registration
      And I click "Save"
     Then I should be redirected to the Manage provider page
      And I should see VAT registration status of "No"
      And I should see a supplier of "D9997"

Scenario: Edit VAT registration for chamber
    Given my provider is a "chamber"
     When I visit the Edit provider page
     Then I should not see the VAT registration checkbox
      And I visit the Manage provider page
     Then I should not see VAT registration information
