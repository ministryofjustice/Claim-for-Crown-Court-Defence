@caseworker
Feature: Claims list sorting
  Background:
    As a caseworker I want to be able to sort the claims I have been allocated and those in the archive

    Given I am a signed in case worker
      And 5 sortable claims have been assigned to me
     When I visit the caseworkers dashboard

  Scenario: Default sorting of claims
     Then I should see "07/01/2016" in top cell of column with link "Date submitted"
      And I click "Date submitted"
     Then I should see "11/01/2016" in top cell of column with link "Date submitted"

  Scenario Outline: Sort claims using header links
      And I click <link_text>
     Then I should see <asc_value> in top cell of column with link <link_text>
      And I click <link_text>
     Then I should see <desc_value> in top cell of column with link <link_text>

    Examples: Column heading text and the results expected of the sorting in a specific order
      | link_text      | asc_value       | desc_value      |
      | "Case number"  | "A00000001"     | "A00000005"     |
      | "Advocate"     | "Billy Smith-A" | "Billy Smith-E" |
      | "Claimed"      | "£1.00"         | "£25.00"        |
      | "Case type"    | "Case Type A"   | "Case Type E"   |

  Scenario: Search then sort claims list by joined attribute does not break
      And I search by the name "%"
      And I click "Claimed"
     Then I should see "£1.00" in top cell of column with link "Claimed"
