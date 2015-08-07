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
       | "submitted"  | 5      |
       | "rejected"   | 5      |
       | "part_paid"  | 5      |
       | "completed"  | 5      |
       | "draft"      | 5      |

  Scenario Outline: View amount assessed for paid and part_paid claims
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has <number> <state> claims
    When I visit the advocates dashboard
    Then I see a column containing the amount assessed for <state> claims
      And a figure representing the amount assessed for <state> claims

    Examples:
       | state        | number |
       | "part_paid"  | 5      |
       # | "completed"  | 5      |

  Scenario Outline: Do not view amount assessed for draft, submitted or rejected claims
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has <number> <state> claims
    When I visit the advocates dashboard
    Then I do not see a column called amount assesed for <state> claims

    Examples:
       | state        | number |
       | "submitted"  | 5      |
       | "rejected"   | 5      |
       | "draft"      | 5      |

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

  Scenario Outline: Claims section titles
    Given I am a signed in advocate
      And There are fee schemes in place
     When I visit the advocates dashboard
     Then I should see section titles of <title>

     Examples:
      | title              |
      | "Draft"            |
      | "Rejected"         |
      | "Submitted to LAA" |
      | "Part paid"        |
      | "Completed"        |

  Scenario Outline: Only relevant columns visible
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have 1 claims of each state
     When I visit the advocates dashboard
     Then I should NOT see column <column_name> under section id <section_id>

    Examples:
      | column_name       | section_id  |
      | "Submission date" | "draft"     |
      | "Paid date"       | "draft"     |
      | "Paid date"       | "rejected"  |
      | "Paid date"       | "submitted" |
