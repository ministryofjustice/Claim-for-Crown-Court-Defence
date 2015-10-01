Feature: Advocate Claims Financial Summary
  Background:
    As an advocate I want to see a financial summary of my claims.

  Scenario: View summary of outstanding claims as an advocate
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have claims
      When I visit the advocates dashboard
     Then I should see my total value of outstanding claims

  Scenario: View summary of outstanding claims as an advocate admin
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see the total value of outstanding claims for my chamber

  Scenario: View summary of authorised claims as an advocate
    Given I am a signed in advocate
      And There are fee schemes in place
      And I have authorised and part authorised claims
     When I visit the advocates dashboard
     Then I should see my total value of authorised and part authorised claims

  Scenario: View summary of authorised claims as an advocate admin
    Given I am a signed in advocate admin
      And There are fee schemes in place
      And my chamber has authorised and part authorised claims
     When I visit the advocates dashboard
     Then I should see the total value of authorised and part authorised claims for my chamber
