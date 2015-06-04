Feature: Claim allocation
  Background:
    As an admin I would like to allocate claims to case workers

    Given I am a signed in admin
      And a case worker exists
      And submitted claims exist

  Scenario: Allocate claims to case worker
     When I visit the case worker allocation page
      And I allocate claims
     Then the case worker should have claims allocated to them
      And the claims should be in an allocated state
      And the claims should be visible on the case worker's dashboard

  Scenario: Removing a caseworker deallocates their claims
     When I visit the case worker allocation page
      And I allocate claims
     When I remove the caseworker
     Then the claims should not be assigned to any case workers
