Feature: User is added by advocate or caseworker admin

Scenario: New advocate user for firm
  Given I am a signed in advocate admin
    And my provider is a "firm"
    And I am on the new "advocate" page
   When I fill in the "advocate" details
    And click save
   Then I see confirmation that a new "Advocate" user has been created
    And an email is sent to the new user

Scenario: New advocate user for chamber
  Given I am a signed in advocate admin
    And my provider is a "chamber"
    And I am on the new "advocate" page
   When I fill in the "advocate" details
    And click save
   Then I see confirmation that a new "Advocate" user has been created
    And an email is sent to the new user

Scenario: New advocate with mismatching email_confirmation
  Given I am a signed in advocate admin
    And my provider is a "chamber"
    And I am on the new "advocate" page
   When I fill in the "advocate" details but email and email_confirmation do not match
    And click save
   Then I see an error message

Scenario: New caseworker user
  Given I am a signed in case worker admin
    And I am on the new "case_worker" page
   When I fill in the "case_worker" details
    And click save
   Then I see confirmation that a new "Case worker" user has been created
    And an email is sent to the new user

Scenario: New caseworker with mismatching email_confirmation
  Given I am a signed in case worker admin
    And I am on the new "case_worker" page
   When I fill in the "case_worker" details but email and email_confirmation do not match
    And click save
   Then I see an error message
