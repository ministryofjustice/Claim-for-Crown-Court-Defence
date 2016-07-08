@javascript
Feature: Case worker admin allocates claims 

  Scenario: I allocate claims, case worker sees them

    Given I am a signed in case worker admin
    And case worker "John Smith" exists
    And submitted claims exist with case numbers "T00000001, T00000002, T00000003, T00000004, T00000005"

    When I visit the allocation page
    And I select claims "T00000001, T00000002"
    And I select case worker "John Smith"
    And I click Allocate
    Then claims "T00000001, T00000002" should be allocated to case worker "John Smith"
    And claims "T00000001, T00000002" should no longer be displayed
    And I should see '2 claims allocated to John Smith'

    Given I sign out
    And I sign in as John Smith
    Then I should be on the 'Your claims' page
    And claims "T00000001, T00000002" should appear on the page
