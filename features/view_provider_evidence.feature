Feature: Using provider evidence to process a claim
  Background: As a signed in caseworker, with claims allocated to me, I want to use evidence from the provider to help me process a claim.

  Scenario: Documents available in evidence list
    Given I am signed in and on the case worker dashboard
      And I have been assigned claims with evidence attached
    When I visit the detailed view for a claim
    Then I see links to view/download each document submitted with the claim

  Scenario: 'Download' link downloads the document, to my downloads directory
    Given I am signed in and on the case worker dashboard
      And I have been assigned claims with evidence attached
    When I visit the detailed view for a claim
      And click on a link to download some evidence
    Then I should get a download with the filename "longer_lorem.pdf"

  Scenario: 'View' link displays evidence in my browser
    Given I am signed in and on the case worker dashboard
      And I have been assigned claims with evidence attached
    When I visit the detailed view for a claim
      And click on a link to view some evidence
    Then I see "longer_lorem.pdf" in my browser

  @wip @javascript @webmock_allow_net_connect
  Scenario: Evidence is displayed in a new tab
    Given I am signed in and on the case worker dashboard
      And I have been assigned claims with evidence attached
    When I visit the detailed view for a claim
      And click on a link to view some evidence
    Then a new tab opens
