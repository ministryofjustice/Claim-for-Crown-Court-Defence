Feature: User is added by advocate or caseworker admin

Scenario: New advocate user
  Given I am a signed in advocate admin
    And I am on the new "advocate" page
  When I fill in the "advocate" details
    And click save
  Then I see confirmation that a new "Advocate" user has been created
    And an email is sent to the new user

Scenario: New caseworker user
  Given I am a signed in case worker admin
    And I am on the new "case_worker" page
  When I fill in the "case_worker" details
    And click save
  Then I see confirmation that a new "Case worker" user has been created
    And an email is sent to the new user