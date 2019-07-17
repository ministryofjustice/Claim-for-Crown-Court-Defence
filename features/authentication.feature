@javascript
Feature: Caseworker can log in while active, but not once inactive

  Scenario: I log in as a case worker admin and I see the allocation page
    Given I insert the VCR cassette 'features/case_workers/admin/allocation'

    And I am a signed in case worker admin
    Then I should be on the Allocation page
    Then the page should be accessible within "#content"
    And I sign out
    And The caseworker is marked as deleted
    And I attempt to sign in again as the deleted caseworker
    Then I should get a page telling me my account has been deleted
    Then the page should be accessible within "#content"

    And I eject the VCR cassette
