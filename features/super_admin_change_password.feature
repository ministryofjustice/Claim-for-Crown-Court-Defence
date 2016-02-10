Feature: Super admin can change password of a user

Scenario: New advocate user for chamber
  Given I am a signed in super admin
    And an advocate user exists
    And I am on the new "external_user" page
   When I fill in the "external_user" details
    And click save
   Then I see confirmation that a new "User" user has been created
    And a welcome email is sent to the new user