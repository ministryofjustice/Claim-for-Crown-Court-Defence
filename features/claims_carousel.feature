Feature: Claims carousel
  Background:
    As a caseworker I want to be able to step through claims I have been
    allocated by clicking "Next claim"

    Given I am a signed in case worker
      And 5 claims have been assigned to me
      And the claims are sorted most recent first

  Scenario: View first claim and step through to the next claim
     When I visit the caseworkers dashboard
      And I click claim 1 in the list
     Then I should see the text "1 of 5"
      And I should see a link to the next claim
     When I click the next claim link
     Then I should be on the claim with id 4

  Scenario: View second claim and step through to the next claim
     When I visit the caseworkers dashboard
      And I click claim 2 in the list
     Then I should see the text "2 of 5"
      And I should see a link to the next claim
     When I click the next claim link
     Then I should be on the claim with id 3

  Scenario: View penultimate claim and step through to the last claim
     When I visit the caseworkers dashboard
      And I click claim 4 in the list
     Then I should see the text "4 of 5"
      And I should see a link to the next claim
     When I click the next claim link
     Then I should be on the claim with id 1
      And I should see the text "5 of 5"
      And I should not see a link to the next claim
