@caseworker
Feature: Case worker viewing and downloading claim evidence

  Background:
    As a caseworker, with claims allocated to me, I want to use evidence from the provider to help me process a claim.

    Given I am signed in and on the case worker dashboard
      And I have been assigned claims with evidence attached

  Scenario: Documents available to caseworkers in evidence list
     When I visit the detail link for a claim
     Then I see links to view/download each document submitted with the claim

  Scenario: Caseworker downloads a document
     When I visit the detail link for a claim
      And click on a link to download some evidence
     Then I should get a download with the filename "longer_lorem.pdf"

  Scenario: Caseworker views a document
     When I visit the detail link for a claim
      And click on a link to view some evidence
    Then I see "longer_lorem.pdf" in my browser
