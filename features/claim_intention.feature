@javascript @webmock_allow_localhost_connect

Feature: Claim intention
  Background:
    As a stakeholder I want to be able to record an intent to create/submit a claim.

    Given I am a signed in advocate

  Scenario: Claim intention created when new claim form modified
    Given I am on the new claim page
      And I trigger a change on a form input
     Then a claim intention should have been created

  Scenario: Claim intention not created when editing a draft claim
    Given a draft claim with documents exists
      And I am on the edit page for the claim
      And I trigger a change on a form input
     Then no claim intention should have been created
