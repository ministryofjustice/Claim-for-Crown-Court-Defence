@advocate
Feature: Advocate archived claims list
  Background:
    As an advocate I want to see all my archived claims.

  @admin
  Scenario: View archived claims list as an advocate admin
    Given I am a signed in advocate admin
      And my provider has 3 "submitted" claims for advocate "John Smith"
      And my provider has 2 "archived_pending_delete" claims for advocate "Bob Smith"
     When I visit the advocate archive
     Then I should see 2 "archived_pending_delete" claims listed
      And I should not see non-archived claims listed

  Scenario: View archived claims list as an advocate
    Given I am a signed in advocate
      And I have 3 "submitted" claims
      And I have 2 "archived_pending_delete" claims
     When I visit the advocate archive
     Then I should see 2 "archived_pending_delete" claims listed
      And I should not see non-archived claims listed

  Scenario Outline: Search archived claims by defendant name
    Given I am a signed in advocate
      And I, advocate, have 3 "submitted" claims involving defendant "Joex Bloggs"
      And I, advocate, have 2 "archived_pending_delete" claims involving defendant "Joex Bloggs"
      And I, advocate, have 1 "archived_pending_delete" claims involving defendant "Fred Bloggs"
      And I, advocate, have 1 "archived_pending_delete" claims involving defendant "Someone Else"
     When I visit the advocate archive
      And I search by the name <defendant_name>
     Then I should only see the <number> claims involving defendant <defendant_name>

     Examples: Search terms and the expected number of results
        | defendant_name     | number  |
        | "Joex Bloggs"      | 2       |
        | "Joex"             | 2       |
        | "Fred Bloggs"      | 1       |
        | "Bloggs"           | 3       |
