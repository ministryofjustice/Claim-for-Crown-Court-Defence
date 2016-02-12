Feature: Claim history
  Background:
    As a case worker or advocate I want to be able to see the claim history.

  Scenario: Advocate claim history should reflect a state change
    Given I am a signed in advocate
      And certification types are seeded
      And I have 1 submitted claim
     When I visit the claim's detail page
     Then I should see the state change to submitted reflected in the history

  Scenario: Case worker claim history should reflect a state change
    Given I am a signed in case worker
      And I have been allocated a claim
     When I visit the claim's case worker detail page
     Then I should see the state change to allocated reflected in the history
