Feature: Caseworker claims list
  Background:
    As a caseworker admin I want to see which claims are allocated or unallocated.

  Scenario: View allocated claims
    Given I am a signed in case worker admin
      And There are fee schemes in place
      And there are allocated claims
     When I visit my dashboard
     Then I should see the allocated claims
      And I should see the claims sorted by oldest first

  Scenario: View unallocated claims
    Given I am a signed in case worker admin
      And There are fee schemes in place
      And there are unallocated claims
     When I visit my dashboard
     Then I should see the unallocated claims
      And I should see the claims sorted by oldest first

  Scenario: View completed claims
    Given I am a signed in case worker admin
      And There are fee schemes in place
      And there are completed claims
     When I visit my dashboard
     Then I should see the completed claims
      And I should see the claims sorted by oldest first

Scenario: View case workers
    Given I am a signed in case worker admin
      And There are fee schemes in place
      And 2 case workers exist
     When I visit my dashboard
     Then I should see an admin link
