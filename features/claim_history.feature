Feature: Claim history
  Background:
    As a case worker or advocate I want to be able to see the claim history.

  Scenario: Advocate claim history should reflect the last edit made
    Given I am a signed in advocate
      And I have a claim in draft state
      And I change the claim's case number to "12345ABC"
     When I visit the claim's detail page
     Then I should see the case number change "12345ABC" reflected in the history

  Scenario: Advocate claim history should reflect a state change
    Given I am a signed in advocate
      And I have a claim in draft state
      And I submit the claim
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit 
     When I visit the claim's detail page
     Then I should see the state change to submitted reflected in the history

  Scenario: Case worker claim history should reflect a state change
    Given I am a signed in case worker
      And I have been allocated a claim
     When I visit the claim's case worker detail page
      And I mark the claim paid in full
     Then I should see the state change to paid in full reflected in the history
