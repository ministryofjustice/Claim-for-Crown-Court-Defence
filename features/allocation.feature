@javascript
Feature: Case worker admin allocates claims

  Scenario: I allocate claims, case worker sees them
    Given case worker "John Smith" exists
    And submitted claims exist with case numbers "T20160001, T20160002, T20160003, T20160004, T20160005"

    And I insert the VCR cassette 'features/case_workers/admin/allocation'

    When I am a signed in case worker admin
    Then the page should be accessible

    When I visit the allocation page
    Then I should see a page title "View the allocation queue"
    And the page should be accessible
    And I should see the AGFS filters

    When I select claims "T20160001, T20160002"
    And I select case worker "John Smith"
    And I click Allocate
    Then I should see '2 claims have been allocated to John Smith'
    And claims "T20160001, T20160002" should be allocated to case worker "John Smith"
    And claims "T20160001, T20160002" should no longer be displayed

    When I enter 2 in the the number of claims field
    And I select case worker "John Smith"
    And I click Allocate
    Then I should see '2 claims have been allocated to John Smith'
    And claims "T20160003, T20160004" should no longer be displayed

    When I sign out
    Then I should see a page title "Help us improve this service"

    When I sign in as John Smith
    Then I should be on the 'Your claims' page
    And I should see a page title "View your allocated claims list"
    And the page should be accessible
    And claims "T20160001, T20160002, T20160003, T20160004" should appear on the page
    And I sign out

    And I eject the VCR cassette
