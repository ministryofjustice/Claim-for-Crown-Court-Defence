Feature: Claim allocation
  Background:
    As an admin I would like to allocate claims to case workers

  Scenario: Allocate claims to case worker
    Given I am a signed in admin
      And a case worker exists
      And submitted claims exist
     When I visit the case worker allocation page
      And I allocate claims
     Then the case worker should have claims allocated to them
      And the claims should be visible on the case worker's dashboard
