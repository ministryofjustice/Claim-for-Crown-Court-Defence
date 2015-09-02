Feature: Advocate claims list
  Background:
    As an advocate I want to see all my claims.

  Scenario: View claims as an advocate
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have claims
     When I visit the advocates dashboard
     Then I should see only claims that I have created

  Scenario: View claims as an advocate admin
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see my chamber's claims

  Scenario Outline: View claims
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has <number> <state> claims
     When I visit the advocates dashboard
     Then I should see my chamber's <number> <state> claims

     Examples:
       | state        | number |
       | "submitted"  | 3      |
       | "rejected"   | 3      |
       | "part_paid"  | 3      |
       | "paid"       | 3      |
       | "draft"      | 3      |

  Scenario: Search claims by advocate name
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has 4 claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the advocate name "John Smith"
     Then I should only see the 4 claims for the advocate "John Smith"

  Scenario Outline: Search claims by defendant name (with optional middlename)
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have 2 claims involving defendant "Joe Bloggs"
      And I have 3 claims involving defendant "Fred Bloggs"
      And I have 1 claims involving defendant "Fred Joe Bloggs"
      And I have 1 claims involving defendant "Joe Fred Bloggs"
      And I have 2 claims involving defendant "Someone Else"
     When I visit the advocates dashboard
      And I search by the name <defendant_name>
     Then I should only see the <number> claims involving defendant <defendant_name>

     Examples:
        | defendant_name    | number  |
        | "Joe Bloggs"      | 4       |
        | "Fred Bloggs"     | 5       |
        | "Joe"             | 4       |
        | "Bloggs"          | 7       |
        | "Fred Joe Bloggs" | 1       |
        | "Joe Fred Bloggs" | 1       |


  Scenario: No search by advocate name for non-admin
    Given I am a signed in advocate
      And There are fee schemes in place
     When I visit the advocates dashboard
     Then I should not see the advocate search field
