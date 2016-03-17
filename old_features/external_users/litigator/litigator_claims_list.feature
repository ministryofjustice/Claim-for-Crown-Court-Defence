@litigator
Feature: Litigator claims list
  Background:
    As an admin in a litigator firm I want to see all the firms claims

  @admin
  Scenario: View claims as a litigator admin
    Given I am a signed in litigator admin
      And my firm has claims
     When I visit the litigators dashboard
     Then I should see all claims

  @litgator
  Scenario: View claims as a litigator
    Given I am a signed in litigator
      And my firm has claims
     When I visit the litigators dashboard
     Then I should see all claims
