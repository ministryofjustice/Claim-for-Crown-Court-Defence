Feature: Guilty plea case type
  Background:
    As an advocate I want to see trial detail fields for
    trial case types only (not guilty plea)

    Given a case type of "Guilty plea" exists
      And a case type of "Contempt" exists

  @javascript @vcr
  Scenario: Guilty plea conditional fields for new claim
    Given I am a signed in advocate
      And I am on the new claim page
     Then I should see the trial detail fields
     When I select2 "Guilty plea" from "claim_case_type_id"
     Then I should not see the trial detail fields
     When I select2 "Contempt" from "claim_case_type_id"
     Then I should see the trial detail fields

  @javascript @vcr
  Scenario: Guilty plea conditional fields for guilty plea existing claim
    Given I am a signed in advocate
      And I am on the edit page for a draft claim of case type "Guilty plea"
     Then I should not see the trial detail fields
     When I select2 "Contempt" from "claim_case_type_id"
     Then I should see the trial detail fields

  @javascript @vcr
  Scenario: Guilty plea conditional fields for non guilty plea existing claim
    Given I am a signed in advocate
      And I am on the edit page for a draft claim of case type "Contempt"
     Then I should see the trial detail fields
     When I select2 "Guilty plea" from "claim_case_type_id"
     Then I should not see the trial detail fields
