Feature: Claim details
  Background:
    As a case worker or advocate I want to view the details of a claim

    Scenario: Case worker views certification details
      Given I am a signed in case worker
        And a certified claim has been assigned to me
        And I visit the claim's case worker detail page
       Then I should see who certified the claim
        And I should see the reason for certification

    Scenario: Case worker views trial details
      Given I am a signed in case worker
        And a trial claim has been assigned to me
        And I visit the case worker claim's detail page
       Then I should see trial details

    Scenario: Case worker views retrial details
      Given I am a signed in case worker
        And a retrial claim has been assigned to me
        And I visit the case worker claim's detail page
       Then I should see retrial details
