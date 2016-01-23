Feature: Claim details
  Background:
    As a case worker or advocate I want to view the details of a claim

    Scenario: Case worker views certification details
      Given I am a signed in case worker
        And a certified claim has been assigned to me
        And I visit the claim's case worker detail page
       Then I should see who certified the claim
        And I should see the reason for certification
