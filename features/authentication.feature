@javascript @no-seed
Feature: Caseworker can log in while active, but not once inactive

  Scenario: I log in as a case worker admin and I see the allocation page
    Given I insert the VCR cassette 'features/case_workers/admin/allocation'

    And I am a signed in case worker admin
    Then I should be on the Allocation page
    Then the page should be accessible
    And I sign out
    And the caseworker is marked as deleted
    And I attempt to sign in again as the deleted caseworker
    Then I should get a page telling me my account has been deleted
    Then the page should be accessible

    And I eject the VCR cassette

  Scenario: Advocate can log in while enabled, and not while not enabled
    Given I am a signed in advocate
    Then I should be on the 'Your claims' page
    And the page should be accessible

    When the advocate is marked as deleted
    And I click the link 'Your claims'
    Then I should be on the sign in page
    And I should see 'This account has been deleted'

    When I attempt to sign in again as the advocate
    Then I should get a page telling me my account has been deleted
    And the page should be accessible

    When the advocate is marked as undeleted
    And I attempt to sign in again as the advocate
    Then I should be on the 'Your claims' page
