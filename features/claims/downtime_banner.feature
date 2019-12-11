@javascript
Feature: A downtime warning banner will appear on every page until downtime date exceeded

  Scenario: I see the downtime warning only upto date of downtime

    Given I am a signed in advocate
    And the current date is '2019-11-20'
    And the downtime feature flag is enabled
    And the downtime date is set to '2019-11-20'
    And I am on the 'Your claims' page

    Then the downtime banner is displayed
    And the downtime banner should say "This service will be unavailable between 4:00pm and 11:59pm on 20 November 2019"
    Then the page should be accessible within "#content"

    When the current date is '2019-11-21'
    And I refresh the page
    Then the downtime banner is not displayed
    Then the page should be accessible within "#content"
