Feature: Management information
  Background:
    As a caseworker I want to be able to download claims information.

    Given I am a signed in case worker admin

  Scenario: Download management information as CSV
   Given There is a Management Information report in the database
     And I am on the management information page
    When I click "Download"
    Then I should have a CSV of the report
