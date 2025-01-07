@javascript @no-seed @vat-seeds
Feature: Case worker admin re-allocates claims

  Background:
    Given I insert the VCR cassette 'features/case_workers/admin/reallocation'
    And a case worker admin user account exists
    And case worker "Kanesha Torphy" exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'T20160001'

  Scenario: Case worker admin can search allocated claims
    Given I sign in as the case worker admin
    Then I should see a page title "View the allocation queue"

    When I click the link 'Re-allocation'
    Then I should see a page title "View the re-allocation queue"
    And I should see 'Displaying 1 claim'

    When I fill in 'Search' with 'does not exist'
    And I click the button 'Search claims'
    Then I should see 'There is no claim available for allocation'

    And I eject the VCR cassette

  Scenario: Case worker admin can re-allocate claims
    Given I sign in as the case worker admin
    Then I should see a page title "View the allocation queue"

    When I click the link 'Re-allocation'
    Then I should see a page title "View the re-allocation queue"
    And I should see 'Displaying 1 claim'
    And the page should be accessible skipping 'aria-allowed-attr'

    When I select case worker "Kanesha Torphy"
    And I click govuk checkbox 'Select case T20160001'
    And I click the button 'Re-allocate'
    Then I should see '1 claim allocated to Kanesha Torphy'
    And the page should be accessible skipping 'aria-allowed-attr'

    When I choose govuk radio "Allocation pool" for "Allocate to"
    And I click govuk checkbox 'Select case T20160001'
    And I click the button 'Re-allocate'
    Then I should see '1 claim returned to allocation pool'
    And claims "T20160001" should no longer be displayed

    And I eject the VCR cassette

