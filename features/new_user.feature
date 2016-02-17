Feature: User is added by advocate or caseworker admin

Scenario: New advocate user for firm
  Given Test mailer is reset
    And I am a signed in advocate admin
    And my provider is a "firm"
    And I am on the new "external_user" page
   When I fill in the "external_user" details
    And I click "Save"
   Then I see confirmation that a new "User" user has been created
    And a welcome email is sent to the new user

Scenario: New advocate user for chamber
  Given Test mailer is reset
    And I am a signed in advocate admin
    And my provider is a "chamber"
    And I am on the new "external_user" page
   When I fill in the "external_user" details
    And I click "Save"
   Then I see confirmation that a new "User" user has been created
    And a welcome email is sent to the new user

Scenario: Advocate user forgets password
  Given Test mailer is reset
    And I am an advocate that has signed in before
    And I am on the Forgot your password? page
   When I fill in my email details
    And I click "Send me password reset instructions"
   Then a password reset email is sent to the user

@javascript @webmock_allow_localhost_connect
Scenario: New external user advocate for chamber
  Given I am a signed in advocate admin
    And my provider is a "chamber"
    And I am on the new "external_user" page
   Then I should not see the supplier number or VAT registration fields
   When I check "Advocate"
   Then I should see the supplier number or VAT registration fields

@javascript @webmock_allow_localhost_connect
Scenario: New external user admin for chamber
  Given I am a signed in advocate admin
    And my provider is a "chamber"
    And I am on the new "external_user" page
   Then I should not see the supplier number or VAT registration fields
   When I check "Admin"
   Then I should not see the supplier number or VAT registration fields

Scenario: New advocate with mismatching email_confirmation
  Given I am a signed in advocate admin
    And my provider is a "chamber"
    And I am on the new "external_user" page
   When I fill in the "external_user" details but email and email_confirmation do not match
    And I click "Save"
   Then I see an error message

Scenario: New caseworker user
  Given Test mailer is reset
    And I am a signed in case worker admin
    And I am on the new "case_worker" page
   When I fill in the "case_worker" details
    And I click "Save"
   Then I see confirmation that a new "Case worker" user has been created
    And a welcome email is sent to the new user

Scenario: New caseworker with mismatching email_confirmation
  Given I am a signed in case worker admin
    And I am on the new "case_worker" page
   When I fill in the "case_worker" details but email and email_confirmation do not match
    And I click "Save"
   Then I see an error message
