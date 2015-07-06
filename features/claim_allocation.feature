Feature: Claim allocation
  Background:
    As a case worker admin I would like to allocate claims to case workers

    Given I am a signed in case worker admin
      And case workers exists
      And submitted claims exist

  Scenario: Allocate claims to case worker
     When I visit the allocation page
      And I select claims
      And I select a case worker
      And I click Allocate
     Then the claims should be allocated to the case worker
      And the allocated claims should no longer be displayed
      And I should see a summary of the claims that were allocated
