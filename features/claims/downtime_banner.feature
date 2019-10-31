# @javascript
Feature: An downtime warning banner will appear on every page until downtime date exceeded

  Scenario: I see the downtime warning only upto date of downtime

    Given I am a signed in advocate
    And the downtime feature flag is enabled
    And the downtime date is set to '2019-11-20'
    And I am on the 'Your claims' page

    Then the downtime banner is visible

    When the downtime date is set to '2019-11-20'
    And I click the link 'Home'
    Then the downtime banner is not visible
