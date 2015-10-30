Feature: User is added by advocate or caseworker admin

Scenario: New advocate user
  Given I am a signed in advocate admin
    And I am on the new user page
  When I fill in the details
    And click submit
  Then I see confirmation that a new user has been created