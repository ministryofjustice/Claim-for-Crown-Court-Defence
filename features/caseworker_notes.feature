Feature: Caseworker notes
  Background:
    As a case worker I want to be able to update the notes on a claim.

    Given There are fee schemes in place

  Scenario: Case worker notes not available to advocates
    Given I am a signed in advocate
      And I have a claim
     When I visit the claim's detail page
     Then I should not see the caseworker notes

  Scenario: Update case worker notes as a case worker
    Given I am a signed in case worker
      And a claim has been assiged to me
     When I visit the the claim's detail page
     Then I should be able to see the caseworker notes
      And I update the caseworker notes
     Then the notes will be saved
