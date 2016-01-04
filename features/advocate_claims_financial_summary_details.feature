Feature: Advocate Claims Financial Summary Details
  Background:
    As an advocate I want to see detailed breakdown of the financial summary of my claims.

  Scenario: View summary of outstanding claims as an advocate
    Given I am a signed in advocate
      And I have claims
     When I visit the advocates dashboard
      And click on the link to view the details of outstanding claims
     Then I should see my total value of outstanding claims
      And I should see a list of outstanding claims

  Scenario: View summary of outstanding claims as an advocate admin
    Given I am a signed in advocate admin
      And my provider has claims
     When I visit the advocates dashboard
      And click on the link to view the details of outstanding claims
      And I should see a list of outstanding claims

  Scenario: View summary of authorised claims as an advocate
    Given I am a signed in advocate
      And I have authorised and part authorised claims
     When I visit the advocates dashboard
      And click on the link to view the details of authorised claims
      And I should see a list of authorised and part authorised claims

  Scenario: View summary of authorised claims as an advocate admin
    Given I am a signed in advocate admin
      And my provider has authorised and part authorised claims
     When I visit the advocates dashboard
      And click on the link to view the details of authorised claims
      And I should see a list of authorised and part authorised claims
