@caseworker
Feature: Caseworker claims list
  Background:
    As a caseworker I want to know what cases I need to process today
    so that I can meet my performance target.

  Scenario: View current claims
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
     Then I should see only my claims
      And I should see the claims sorted by oldest first

  Scenario: View archived claims
    Given I am a signed in case worker
      And I have archived claims
     When I visit my dashboard
      And I click "Archive"
     Then I should see only my claims
      And I should see the claims sorted by oldest first

  Scenario: Search for claims by MAAT reference
    Given I am signed in and on the case worker dashboard
     When I search for a claim by MAAT reference
     Then I should only see claims matching the MAAT reference

  Scenario Outline: Search my "Current" and "Archive" claims
    Given I am a signed in case worker
      And I have 3 "allocated" claims involving defendant "Joex Bloggs"
      And I have 1 "allocated" claims involving defendant "Fred Bloggs"
      And I have 2 "authorised" claims involving defendant "Joex Bloggs"
      And I have 3 "authorised" claims involving defendant "Fred Bloggs"
      And I have 1 "part_authorised" claims involving defendant "Fred Bloggs"
      And I have 2 "part_authorised" claims involving defendant "Someone Else"
     When I visit my dashboard
      And I search claims by defendant name <defendant_name>
     Then I should only see <current_number> claims
      And the claim count should show <current_number>
     When I click "Archive"
      And I search claims by defendant name <defendant_name>
     Then I should only see <archive_number> claims
      And the claim count should show <archive_number>

     Examples: List of defendants and the number of live/archive claims they're involved in
        | defendant_name | current_number | archive_number |
        | "Joex Bloggs"  | 3              | 2              |
        | "Fred Bloggs"  | 1              | 4              |
        | "Bloggs"       | 4              | 6              |
