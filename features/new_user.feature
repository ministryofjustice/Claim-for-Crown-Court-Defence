Feature: User is added by advocate or caseworker admin

Scenario: New advocate user for firm
  Given I am a signed in advocate admin
    And my provider is a "firm"
    And I am on the new "external_user" page
   When I fill in the "external_user" details
    And click save
   Then I see confirmation that a new "User" user has been created
    And a welcome email is sent to the new user

@javascript @webmock_allow_localhost_connect
Scenario: VAT registration and supplier number field visibility
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
    And click save
   Then I see an error message

Scenario: New caseworker user
  Given I am a signed in case worker admin
    And I am on the new "case_worker" page
   When I fill in the "case_worker" details
    And click save
   Then I see confirmation that a new "Case worker" user has been created
    And a welcome email is sent to the new user
