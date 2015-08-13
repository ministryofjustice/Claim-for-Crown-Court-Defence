Feature: Caseworker claims list
  Background:
    As a caseworker I want to know what cases I need to process today
    so that I can meet my performance target.

  Scenario: View current claims
    Given I am a signed in case worker
      And There are fee schemes in place
      And claims have been assigned to me
     When I visit my dashboard
     Then I should see only my claims
      And I should see the claims sorted by oldest first

  #Scenario: View completed claims
  #  Given I am a signed in case worker
  #    And There are fee schemes in place
  #    And I have completed claims
  #   When I visit my dashboard
    #  And I click on the Completed Claims tab
    # Then I should see only my claims
  #    Then I should see the claims sorted by oldest first

  Scenario: Sort current claims by oldest first
    Given I am signed in and on the case worker dashboard
     When I sort the claims by oldest first
     Then I should see the claims sorted by oldest first

  Scenario: Sort current claims by highest value
    Given I am signed in and on the case worker dashboard
     When I sort the claims by highest value first
     Then I should see the claims sorted by highest value first

  Scenario: Sort current claims by lowest value
    Given I am signed in and on the case worker dashboard
     When I sort the claims by lowest value first
     Then I should see the claims sorted by lowest value first

#  Scenario: Current claims count
#    Given I am signed in and on the case worker dashboard
#     Then I should see the claims count

  Scenario: Search for claims by MAAT reference
    Given I am signed in and on the case worker dashboard
     When I search for a claim by MAAT reference
     Then I should only see claims matching the MAAT reference

  Scenario Outline: Search current and completed claims by defendant name
    Given I am signed in and on the case worker dashboard
      And I have 2 "allocated" claims involving defendant "Joe Bloggs"
      And I have 3 "allocated" claims involving defendant "Fred Bloggs"
      And I have 2 "completed" claims involving defendant "Joe Bloggs"
      And I have 3 "completed" claims involving defendant "Fred Bloggs"
      And I have 2 "completed" claims involving defendant "Someone Else"
     When I visit my dashboard
      And I search claims by defendant name <defendant_name>
     Then I should only see <number> "Current" claims
    #  And I click on the Completed Claims tab
    # Then I should only see <number> "Completed" claims

     Examples:
        | defendant_name | number |
        | "Joe Bloggs"   | 2      |
        | "Fred Bloggs"  | 3      |
        | "Bloggs"       | 5      |
