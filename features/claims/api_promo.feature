@javascript
Feature: An API promotion banner will appear on the create claim page, until the user dismisses it

  Scenario: I go to the create a claim page, should see an API promo banner, dismiss it and do not see it again

    Given I am a signed in advocate
    And The API promo feature flag is enabled
    And I am on the 'Your claims' page
    When I click 'Start a claim'
    Then I should be on the new claim page

    And The API promo banner is visible
    When I click the link 'Do not show me again'
    Then The API promo banner is not visible
    When I reload the page
    Then The API promo banner is not visible
