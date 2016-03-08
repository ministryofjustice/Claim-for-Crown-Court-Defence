@caseworker
Feature: Caseworker claims list
  Background:
    As a caseworker I want to know what cases I need to process today
    so that I can meet my performance target.

  Scenario: View current claims
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
     Then I should see only my claims
      And I should see the claims sorted by oldest first

  Scenario: View archived claims
    Given I am a signed in case worker
      And I have archived claims
     When I visit my dashboard
      And I click "Archive"
     Then I should see only my claims
      And I should see the claims sorted by oldest first

  Scenario: Search for claims by MAAT reference
    Given I am signed in and on the case worker dashboard
     When I search for a claim by MAAT reference
     Then I should only see claims matching the MAAT reference
