Feature: Caseworker claims list
  Background:
    As a caseworker admin I want to see which claims are allocated or unallocated.

  Scenario: View my current claims
   Given I am a signed in case worker admin
     And claims have been assigned to me
    When I visit my dashboard
     And I click "Your claims"
    Then I should see only my claims
     And I should see the claims sorted by oldest first

  Scenario: View all archived claims
   Given I am a signed in case worker admin
     And there are archived claims
    When I visit my dashboard
     And I click "Archive"
    Then I should see all archived claims
     And I should see the claims sorted by oldest first

  Scenario: View allocation tool
   Given I am a signed in case worker admin
     And there are unallocated claims
    When I visit my dashboard
     And I click "Allocation"
    Then I should see the unallocated claims

  Scenario: View re-allocation tool
   Given I am a signed in case worker admin
     And there are allocated claims
    When I visit my dashboard
     And I click "Re-allocation"
    Then I should see the allocated claims

  Scenario: View case workers
    Given I am a signed in case worker admin
      And 2 case workers exist
     When I visit my dashboard
     Then I should see the admin caseworkers Manage case workers link and it should work
      And I should see the case workers edit and delete link
