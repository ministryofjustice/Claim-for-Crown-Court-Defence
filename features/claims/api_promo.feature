@javascript
Feature: An API promotion banner will appear on the create claim page, until the user dismisses it

  Scenario: I go to the create a claim page, should see an API promo banner, dismiss it and do not see it again

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    When I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And The API promo banner is visible
    Then the page should be accessible skipping 'aria-allowed-attr'
    When I click the link 'Do not show API information again'
    Then The API promo banner is not visible

    When I click the link 'Home'
    And I click 'Start a claim'
    Then The API promo banner is not visible
