
Feature: Advocate editing of existing claims

  Scenario: Edit a draft claim to have errors and submit to LAA
    Given I am a signed in advocate
      And a claim exists with state "draft"
    When I am on the claim edit page
      And I render the claim invalid
      And I submit to LAA
    Then I should be redirected back and errors displayed

  # TODO: reintroduce once this validation is reapplied in a suitable manner
 # Scenario: Edit a draft claim to remove all fees or claims, then submit to LAA
 #    Given I am a signed in advocate
 #      And a claim exists with state "draft"
 #     When I am on the claim edit page
 #      And I delete all fees and expenses
 #      And I submit to LAA
 #     Then I should be redirected back and errors displayed
