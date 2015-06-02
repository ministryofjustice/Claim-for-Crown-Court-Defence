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
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see my chamber's claims

  Scenario Outline: View claims
    Given I am a signed in advocate admin
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
      And my chamber has <number> <state> claims
    When I visit the advocates dashboard
    Then I see a column called amount assesed for <state> claims
      And I see a figure representing the amount assessed for <state> claims

    Examples:
       | state        | number |
       | "part_paid"  | 5      |
       | "completed"  | 5      |

  Scenario Outline: Do not view amount assessed for draft, submitted or rejected claims
    Given I am a signed in advocate admin
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
      And my chamber has 4 claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the advocate name "John Smith"
     Then I should only see the 4 claims for the advocate "John Smith"

  Scenario: Search claims by defendant name
    Given I am a signed in advocate
      And I have 2 claims involving defendant "Joe Bloggs" amongst others
      And I have 3 claims involving defendant "Fred Bloggs" amongst others
     When I visit the advocates dashboard
      And I search by the defendant name "Joe Bloggs"
     Then I should only see the 2 claims involving defendant "Joe Bloggs"
      And I search by the defendant name "Fred Bloggs"
     Then I should only see the 3 claims involving defendant "Fred Bloggs"
      And I search by the defendant name "Bloggs"
     Then I should only see the 5 claims involving defendant "Bloggs"

 Scenario Outline: Search claims by advocate and defendant name
  Given I am a signed in advocate admin
    And signed in advocate's chamber has 2 claims for advocate "Fred Dibna" with defendant "Fred Bloggs"
    And signed in advocate's chamber has 3 claims for advocate "Joe Adlott" with defendant "Joe Bloggs"
   When I visit the advocates dashboard
    And I enter advocate name of <advocate_name>
    And I enter defendant name of <defendant_name>
    And I hit search button
   Then I should only see the <claim_count> claims involving defendant <defendant_name>

   Examples:
      | advocate_name | defendant_name | claim_count |
      | "Fred Dibna"  | "Joe Bloggs"   | 0           |
      | "Fred Dibna"  | "Fred Bloggs"  | 2           |
      | "Joe Adlott"  | "Joe Bloggs"   | 3           |

  Scenario: No search by advocate name for non-admin
    Given I am a signed in advocate
     When I visit the advocates dashboard
     Then I should not see the advocate search field

  Scenario Outline: Claims section titles
    Given I am a signed in advocate
     When I visit the advocates dashboard
     Then I should see section titles of <title>

     Examples:
      | title              |
      | "Draft"            |
      | "Rejected"         |
      | "Submitted to LAA" |
      | "Part paid"        |
      | "Completed"        |
