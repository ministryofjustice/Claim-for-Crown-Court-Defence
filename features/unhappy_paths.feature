Feature: Unhappy paths
  Background:
    As an advocate saving drafts and submitting claims I want to be sure that error messages are displayed if I do something wrong

  Scenario: Attempt to sign in with wrong password
    Given I attempt to sign in with an incorrect password
    Then I should be redirected back to the sign in page
    And I should see a sign in error message

  Scenario: Attempt to save draft claim as advocate admin without specifying the advocate
    Given I am a signed in advocate admin
    And There are case types in place
    And I am on the new claim page
    And I fill in the claim details omitting the advocate
    When I save to drafts
    Then I should be redirected back to the create claim page
    And The entered values should be preserved on the page
    And I should see the error message "Advocate cannot be blank"

  Scenario: Attempt to submit claim to LAA without specifying all fields
    Given I am a signed in advocate
    And There are case types in place
    And I am on the new claim page
    And I attempt to submit to LAA without specifying all the details
    Then I should be redirected back to the create claim page
    And I should see the error message "Case number cannot be blank"
