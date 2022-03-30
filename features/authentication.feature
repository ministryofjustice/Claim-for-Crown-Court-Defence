@javascript @no-seed
Feature: Caseworker can log in while active, but not once inactive

  Scenario: I log in as a case worker admin and I see the allocation page
    Given I insert the VCR cassette 'features/case_workers/admin/allocation'

    Given I am a signed in case worker admin
    Then I should be on the Allocation page
    And the page should be accessible
    And I sign out

    Given the caseworker is marked as deleted
    When I attempt to sign in again as the deleted caseworker
    Then I should see 'This account has been deleted'
    And the page should be accessible

    And I eject the VCR cassette

  Scenario: Advocate can log in while enabled, and not while not enabled
    Given I am a signed in advocate
    Then I should be on the 'Your claims' page
    And the page should be accessible

    Given the advocate is disabled
    When I click the link 'Your claims'
    Then I should be on the sign in page
    And I should see 'This account has been disabled'

    When I attempt to sign in again as the advocate
    Then I should see 'This account has been disabled'
    And the page should be accessible

    Given the advocate is enabled
    When I attempt to sign in again as the advocate
    Then I should be on the 'Your claims' page
