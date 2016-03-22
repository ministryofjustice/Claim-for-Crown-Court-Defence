Feature: Claim history
  Background:
    As a case worker or advocate I want to be able to see the claim history.

  @javascript @webmock_allow_localhost_connect
  Scenario: Advocate claim history should reflect a state change
    Given I am a signed in advocate
      And certification types are seeded
      And I have a claim in draft state
      And I submit the claim
     Then I should be redirected to the claim summary page
     When I click 'Continue'
     Then I should be redirected to the claim certification page
      And I fill in the certification details and submit
     When I visit the claim's detail page
      And I expand the accordion
     Then I should see the state change to submitted reflected in the history

  @javascript @webmock_allow_localhost_connect
  Scenario: Case worker claim history should reflect a state change
    Given I am a signed in case worker
      And I have been allocated a claim
     When I visit the claim's case worker detail page
      And I expand the accordion
      And I mark the claim authorised
     Then the messages section should be expanded
      And I should see the state change to authorised reflected in the history
