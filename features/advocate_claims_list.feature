Feature: Advocate claims list
  Background:
    As an advocate I want to see all my claims.

  Scenario: View claims as an advocate
    Given I am a signed in advocate
      And I have claims
     When I visit the advocates dashboard
     Then I should see only claims that I have created

  Scenario: View claims as an advocate admin
    Given I am a signed in advocate admin
      And my chamber has claims
     When I visit the advocates dashboard
     Then I should see my chamber's claims

  Scenario: View current claims
    Given I am a signed in advocate admin
      And my chamber has 5 "current" claims
     When I visit the advocates dashboard
     Then I should see my chamber's 5 "current" claims

  Scenario: View completed claims
    Given I am a signed in advocate admin
      And my chamber has 5 "completed" claims
     When I visit the advocates dashboard
     Then I should see my chamber's 5 "completed" claims

  Scenario: View draft claims
    Given I am a signed in advocate admin
      And my chamber has 5 "draft" claims
     When I visit the advocates dashboard
     Then I should see my chamber's 5 "draft" claims

  Scenario: Search claims by advocate name
    Given I am a signed in advocate admin
      And my chamber has 4 claims for advocate "John Smith"
     When I visit the advocates dashboard
      And I search by the advocate name "John Smith"
     Then I should only see the 4 claims for the advocate "John Smith"

  Scenario: No search by advocate name for non-admin
    Given I am a signed in advocate
     When I visit the advocates dashboard
     Then I should not see the advocate search field
