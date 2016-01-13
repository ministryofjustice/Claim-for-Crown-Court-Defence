Feature: Claims list sorting
  Background:
    As a caseworker I want to be able to sort the claims I have been allocated and those in the archive

    Given I am a signed in case worker
      And 5 sortable claims have been assigned to me
     When I visit the caseworkers dashboard

  Scenario: Default sorting of claims
     Then I should see "07/01/2016" in top cell of column "Date submitted"
      And I click "Date submitted"
     Then I should see "11/01/2016" in top cell of column "Date submitted"

  Scenario Outline: Sort claims by case number
      And I click <header_title>
     Then I should see <asc_value> in top cell of column <header_title>
      And I click <header_title>
     Then I should see <desc_value> in top cell of column <header_title>

    Examples:
      | header_title      | asc_value       | desc_value      |
      | "Case number"     | "A00000001"     | "A00000005"     |
      | "Advocate"        | "Billy Smith-A" | "Billy Smith-E" |
      | "Claimed"         | "£1.00"         | "£25.00"        |
      | "Case type"       | "Case Type A"   | "Case Type E"   |
