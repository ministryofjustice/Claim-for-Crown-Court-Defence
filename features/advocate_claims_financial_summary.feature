Feature: Advocate Claims Financial Summary
  Background:
    As an advocate I want to see a financial summary of my claims.

  Scenario: View summary of outstanding claims as an advocate
    Given I am a signed in advocate
      And I have claims
     When I visit the advocates dashboard
     Then I should see my total value of outstanding claims

  @wip
  Scenario: View summary of outstanding claims as an advocate admin
    Given I am a signed in advocate admin
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see the total value of outstanding claims for my chamber

  @wip
  Scenario: View summary of authorised claims as an advocate
    Given I am a signed in advocate
      And I have claims
     When I visit the advocates dashboard
     Then I should see my total value of authorised claims

  @wip
  Scenario: View summary of authorised claims as an advocate admin
    Given I am a signed in advocate admin
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see the total value of authorised claims for my chamber
