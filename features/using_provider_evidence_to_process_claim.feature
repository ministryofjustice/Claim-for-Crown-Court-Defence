Feature: Using provider evidence to process a claim
  Background: As a signed in caseworker, with claims allocated to me, I want to use evidence from the provider to help me process a claim.

  Scenario: Evidence in detailed claim view
    Given I am signed in and on the case worker dashboard
    When I visit the detailed view for a claim
    Then I should see associated evidence from the provider
