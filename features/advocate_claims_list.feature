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

  Scenario: Claims list exludes archived claims (advocate admin)
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has 3 "submitted" claims for advocate "John Smith"
      And my chamber has 2 "archived_pending_delete" claims for advocate "Bob Smith"
     When I visit the advocates dashboard
     Then I should see 3 "submitted" claims listed
      And I should not see archived claims listed

  Scenario: Claims list exludes archived claims (advocate)
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have 3 "submitted" claims
      And I have 2 "archived_pending_delete" claims
     When I visit the advocates dashboard
     Then I should see 3 "submitted" claims listed
      And I should not see archived claims listed

  Scenario: Search claims by advocate name
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has 4 claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the advocate name "John Smith"
     Then I should only see the 4 claims for the advocate "John Smith"

  Scenario: Search claims by advocate name excludes archived
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has 3 "submitted" claims for advocate "John Smith"
      And my chamber has 2 "archived_pending_delete" claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the advocate name "John Smith"
     Then I should only see the 3 claims for the advocate "John Smith"

  Scenario Outline: Search claims by defendant name (with optional middlename)
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have 2 claims involving defendant "Joex Bloggs"
      And I have 3 claims involving defendant "Fred Bloggs"
      And I have 1 claims involving defendant "Fred Joex Bloggs"
      And I have 1 claims involving defendant "Joex Fred Bloggs"
      And I have 2 claims involving defendant "Someone Else"
     When I visit the advocates dashboard
      And I search by the name <defendant_name>
     Then I should only see the <number> claims involving defendant <defendant_name>

     Examples:
        | defendant_name     | number  |
        | "Joex Bloggs"      | 4       |
        | "Fred Bloggs"      | 5       |
        | "Joex"             | 4       |
        | "Bloggs"           | 7       |
        | "Fred Joex Bloggs" | 1       |
        | "Joex Fred Bloggs" | 1       |
