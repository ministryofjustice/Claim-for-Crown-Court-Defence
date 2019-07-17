@javascript
Feature: Case worker admin allocates claims

  Scenario: I allocate claims, case worker sees them
    Given case worker "John Smith" exists
    And submitted claims exist with case numbers "T20160001, T20160002, T20160003, T20160004, T20160005"

    And I insert the VCR cassette 'features/case_workers/admin/allocation'

    And I am a signed in case worker admin
    Then the page should be accessible within "#content"
    When I visit the allocation page
    Then I should see a page title "View the allocation queue"
    Then the page should be accessible within "#content"
    And I should see the AGFS filters
    And I select claims "T20160001, T20160002"
    And I select case worker "John Smith"
    And I click Allocate
    Then claims "T20160001, T20160002" should be allocated to case worker "John Smith"
    And claims "T20160001, T20160002" should no longer be displayed
    And I should see '2 claims have been allocated to John Smith'
    Then the page should be accessible within "#content"
    And I sign out
    Then I should see a page title "Help us improve this service"
    When I sign in as John Smith
    Then I should be on the 'Your claims' page
    Then I should see a page title "View your allocated claims list"
    Then the page should be accessible within "#content"
    And claims "T20160001, T20160002" should appear on the page
    And I sign out

    And I eject the VCR cassette
