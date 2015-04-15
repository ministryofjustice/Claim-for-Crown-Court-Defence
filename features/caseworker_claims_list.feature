Feature: Caseworker claims list
  Background:
    As a caseworker I want to know what cases I need to process today
    so that I can meet my performance target.

  Scenario: View current claims
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
     Then I should see only my claims
      And the claims should be sorted by oldest first

  Scenario: Sort current claims by newest first
    Given I am signed in and on the case worker dashboard
     When I sort the the claims by newest first
     Then I should see the claims sorted by newest first

  Scenario: Sort current claims by highest value
    Given I am signed in and on the case worker dashboard
     When I sort the the claims by highest value first
     Then I should see the claims sorted by highest value first

  Scenario: Sort current claims by lowest value
    Given I am signed in and on the case worker dashboard
     When I sort the the claims by lowest value first
     Then I should see the claims sorted by lowest value first

  Scenario: Current claims count
    Given I am signed in and on the case worker dashboard
     Then I should see the claims count
