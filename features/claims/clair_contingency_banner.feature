@javascript
Feature: A clair contingency banner will appear on the choose your bill type page, until the user dismisses it

  Scenario: I go to the 'Choose your bill type page' and the clair contingency banner, dismiss it and do not see it again

    Given I am a signed in advocate
    And The clair contingency banner feature flag is enabled
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    Then The clair contingency banner is visible
    Then the page should be accessible

    When I click the link 'Do not show main hearing date information again'
    Then The clair contingency banner is not visible

    When I click the link 'Claim for Crown Court defence'
    Then I am on the 'Your claims' page
    And I click 'Start a claim'
    Then The clair contingency banner is not visible
