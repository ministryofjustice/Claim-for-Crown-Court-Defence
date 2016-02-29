Feature: Cracked trial
  Background:
    As an advocate i want to see cracked trial detail fields for
    cracked trial case types only. Submission should validate these.

    Given a case type of "Cracked trial" exists
      And a case type of "Cracked before retrial" exists
      And a case type of "Contempt" exists

  @javascript @webmock_allow_localhost_connect
  Scenario: Cracked trial conditional fields
    Given I am a signed in advocate
      And I am on the new claim page
     Then I should NOT see Cracked trial fields
      And I select2 a Case Type of "Cracked trial"
     Then I should see Cracked trial fields
      And I select2 a Case Type of "Contempt"
     Then I should NOT see Cracked trial fields

  @javascript @webmock_allow_localhost_connect
  Scenario: Cracked before retrial requires final third
    Given I am a signed in advocate
      And There are case types in place
      And certification types are seeded
      And I am on the new claim page
      And I select2 a Case Type of "Cracked before retrial"
      And I fill in cracked trial dates
      And I choose radio button "First third"
      And I submit to LAA
     Then I should see summary error ""Case cracked in" can only be Final Third for trials that cracked before retrial"
     When I choose radio button "Final third"
      And I submit to LAA
     Then I should not see summary error ""Case cracked in" can only be Final Third for trials that cracked before retrial"
