@advocate @admin
Feature: Manage Advocate
  Background:
    As an advocate admin I should be able to add/edit advocates and I should be
    able to find existing advocates by first/last name
    Given 12 advocates exists

  Scenario: Search for existing advocates
    Given I am a signed in advocate admin
     When I visit Manage advocates page
     Then I should see all advocates
     When I search for an advocate
     Then I should see the advocate in the results
