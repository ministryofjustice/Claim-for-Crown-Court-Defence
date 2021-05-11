@javascript @no-seed
Feature: A downtime warning banner appears on home pages only until downtime date exceeded

  Scenario: Downtime warning active until 26 May 2021
    Given I am a signed in advocate
    And the downtime feature flag is enabled
    And the downtime date is set to '2021-05-26'

    When the current date is '2021-05-19'
    And I am on the 'Your claims' page
    Then the downtime banner is displayed
    And the downtime banner should say "This service will be unavailable on 26 May 2021 from 5pm until midnight"
    And the page should be accessible

    When I click 'Start a claim'
    Then I am on the fee scheme selector page
    And the downtime banner is not displayed
    And I go back
    And I am on the 'Your claims' page

    When the current date is '2021-05-26'
    And I refresh the page
    Then the downtime banner is displayed

    When the current date is '2021-05-27'
    And I refresh the page
    Then the downtime banner is not displayed
