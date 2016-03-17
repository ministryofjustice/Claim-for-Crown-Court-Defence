@caseworker @admin
Feature: Manage Caseworkers
  Background:
    As a caseworker admin I should be able to add/edit case workers and I should be
    able to find existing case workers by first/last name
    Given 12 case workers exists

  Scenario: Search for existing case workers
    Given I am a signed in case worker admin
     When I visit Manage case workers page
     Then I should see all case workers
     When I search for a case worker
     Then I should see the case worker in the results
