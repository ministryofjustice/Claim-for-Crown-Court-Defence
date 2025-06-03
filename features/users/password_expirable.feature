@no-seed
Feature: Password expiring after set time

  Scenario: Able to log in 364 days after password set
    Given the current date is '2025-01-01'
    And I am a signed in advocate
    Then I should be on the 'Your claims' page

    When the current date is '2025-12-31'
    And I attempt to sign in again as the advocate
    Then I should be on the 'Your claims' page

  Scenario: Unable to log in 366 days after password set
    Given the current date is '2025-01-01'
    And I am a signed in advocate
    Then I should be on the 'Your claims' page

    When the current date is '2026-01-02'
    And I attempt to sign in again as the advocate
    Then I should see 'Invalid Email or password.'

