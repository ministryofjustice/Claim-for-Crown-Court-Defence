@advocate @admin @spec
Feature: Claims list sorting
  Background:
    As an advocate I want to be able to sort the claims in my lists of current, archived, outstanding
    and authorised claims

    Given I am a signed in advocate admin
      And I have 5 sortable claims
     When I visit the advocates dashboard

  Scenario: Default sorting of claims (draft/unsubmitted first)
     Then I should see "" in top cell of column with link "Date submitted"
      And I click "Date submitted"
     Then I should see "10/01/2016" in top cell of column with link "Date submitted"

  Scenario Outline: Sort claims using header links
      And I click <link_text>
     Then I should see <asc_value> in top cell of column with link <link_text>
      And I click <link_text>
     Then I should see <desc_value> in top cell of column with link <link_text>

    Examples: Column headings and expected sort order response
      | link_text      | asc_value       | desc_value      |
      | "Case number"  | "A00000001"     | "A00000005"     |
      | "Advocate"     | "Billy Smith-A" | "Billy Smith-E" |
      | "Claimed"      | "£1.00"         | "£25.00"        |
      | "Assessed"     | "-"             | "£18.80"        |
      | "Status"       | "Allocated"     | "Submitted"     |

  Scenario: Search then sort claims list by joined attribute does not break
      And I search by the name "%"
      And I click "Assessed"
     Then I should see "-" in top cell of column with link "Assessed"
