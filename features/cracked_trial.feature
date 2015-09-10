Feature: Cracked trial
  Background:
    As an advocate i want to see cracked trial detail fields for
    cracked trial case types only

    Given a case type of "Cracked Trial" exists
      And a case type of "Contempt" exists

  @javascript
  Scenario: Cracked trial conditional fields
    Given I am a signed in advocate
      And I am on the new claim page
     Then I should NOT see Cracked Trial fields
      And I select2 "Cracked Trial" from "claim_case_type_id"
     Then I should see Cracked Trial fields
      And I select2 "Contempt" from "claim_case_type_id"
     Then I should NOT see Cracked Trial fields
