Feature: Advocate claims list
  Background:
    As an advocate I want to see all my claims.

  Scenario: View claims as an advocate
    Given I am a signed in advocate
      And I have claims
     When I visit the advocates dashboard
     Then I should see only claims that I have created

  Scenario: View claims as an advocate admin
    Given I am a signed in advocate admin
      And my provider has claims
     When I visit the advocates dashboard
     Then I should see my provider's claims

  Scenario Outline: View claims
    Given I am a signed in advocate admin
      And my provider has <number> <state> claims
     When I visit the advocates dashboard
     Then I should see my provider's <number> <state> claims

     Examples:
       | state                      | number |
       | "submitted"                | 3      |
       | "rejected"                 | 3      |
       | "part_authorised"          | 3      |
       | "authorised"               | 3      |
       | "draft"                    | 3      |
       | "redetermination"          | 3      |
       | "awaiting_written_reasons" | 3      |

  Scenario: Claims list exludes archived claims (advocate admin)
    Given I am a signed in advocate admin
      And my provider has 3 "submitted" claims for advocate "John Smith"
      And my provider has 2 "archived_pending_delete" claims for advocate "Bob Smith"
     When I visit the advocates dashboard
     Then I should see 3 "submitted" claims listed
      And I should not see archived claims listed

  Scenario: Claims list exludes archived claims (advocate)
    Given I am a signed in advocate
      And I have 3 "submitted" claims
      And I have 2 "archived_pending_delete" claims
     When I visit the advocates dashboard
     Then I should see 3 "submitted" claims listed
      And I should not see archived claims listed

  Scenario: Search claims by advocate name
    Given I am a signed in advocate admin
      And my provider has 4 claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the name "John Smith"
     Then I should only see the 4 claims for the advocate "John Smith"

  Scenario: Search claims by advocate name excludes archived
    Given I am a signed in advocate admin
      And my provider has 3 "submitted" claims for advocate "John Smith"
      And my provider has 2 "archived_pending_delete" claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the name "John Smith"
     Then I should only see the 3 claims for the advocate "John Smith"

  Scenario Outline: Search claims by defendant name
    Given I am a signed in advocate
      And I have 2 claims involving defendant "Joex Bloggs"
      And I have 3 claims involving defendant "Fred Bloggs"
      And I have 2 claims involving defendant "Someone Else"
     When I visit the advocates dashboard
      And I search by the name <defendant_name>
     Then I should only see the <number> claims involving defendant <defendant_name>

     Examples:
        | defendant_name     | number  |
        | "Joex Bloggs"      | 2       |
        | "Fred Bloggs"      | 3       |
        | "Joex"             | 2       |
        | "Bloggs"           | 5       |
        | "Fred Joex Bloggs" | 0       |
        | "Joex Fred Bloggs" | 0       |
