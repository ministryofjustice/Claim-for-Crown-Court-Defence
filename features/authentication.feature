@javascript
Feature: Caseworker can log in while active, but not once inactive

  Scenario: I log in as a case worker admin and I see the allocation page

    Given I am a signed in case worker admin
    Then I should be on the Allocation page
    And I sign out as case_worker
    And The caseworker is marked as deleted
    And I attempt to sign in again as the deleted caseworker
    Then I should get a page telling me my account has been deleted


