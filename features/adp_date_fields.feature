Feature: ADP date fields
  Background:
    As an advocate I want to be able to enter dates in day, month, year fields.

  Scenario Outline: Fill in first day of trial
    Given I am a signed in advocate
      And I am on the new claim page
      And I fill in the first day of trial with <format>
     When I save to drafts
     Then the claim's first day of trial should be <expected>

    Examples:
      | format        | expected   |
      | 4-10-80       | 00801004   |
      | 04-10-1980    | 19801004   |
      | 04-Oct-1980   | 19801004   |
      | 4-jAn-1999    | 19990104   |
