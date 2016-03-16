@advocate
Feature: Advocate viewing and downloading claim evidence

  Background:
    As an advocate, I want to check evidence that I have provided as part of my claim

    Given I am a signed in advocate
      And I have claims

  Scenario: Documents available to advocates in evidence list
     When I view the claim
     Then I see links to view/download each document submitted with the claim

  Scenario: Advocate downloads a document
    When I view the claim
      And click on a link to download some evidence
    Then I should get a download with the filename "longer_lorem.pdf"

  Scenario: Advocate views a document
     When I view the claim
      And click on a link to view some evidence
     Then I see "longer_lorem.pdf" in my browser
