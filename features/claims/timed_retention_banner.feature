@javascript
Feature: A timed retention banner will appear on the claims list, until the user dismisses it

  Scenario: I go to the claims page, should see the timed retention banner, dismiss it and do not see it again

    Given I am a signed in advocate
    And I am on the 'Your claims' page

    Then The timed retention banner is visible
    Then the page should be accessible
    When I click the link 'Do not show time-limited retention information again'
    Then The timed retention banner is not visible
    When I click 'Your claims' link
    Then The timed retention banner is not visible
    Then the page should be accessible
