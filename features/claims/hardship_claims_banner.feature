@javascript
Feature: A hardship claims banner will appear on the claims list, until the user dismisses it

  Scenario: I go to the claims select page and the hardship claims banner, dismiss it and do not see it again

    Given I am a signed in advocate
    And The hardship claims banner feature flag is enabled
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    Then The hardship claims banner is visible
    And the page should be accessible within "#content"

    When I click the link 'Do not show this message again'
    Then The hardship claims banner is not visible

    When I click the link 'Home'
    Then I am on the 'Your claims' page
    And I click 'Start a claim'
    Then The hardship claims banner is not visible
