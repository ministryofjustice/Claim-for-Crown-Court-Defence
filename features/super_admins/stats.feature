@javascript
Feature: Stats

  Scenario: Changing the dates on the stats page
    Given I am a signed in super admin
    Given I have created test claims for "10/08/2022"
    When I visit "/super_admins/stats"
    And I enter the From date "01/8/2022"
    And I enter the To date "31/8/2022"
    And I click Update
    Then the Javascript variable createChart should change
