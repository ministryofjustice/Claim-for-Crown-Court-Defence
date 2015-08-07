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
      | 04-10-80      | 00801004   |
      # | 04-10-1980    | 19801004   |
      # | 04-1-1980     | 19800104   |
      # | 4-1-1980      | 19800104   |
      # | 4-10-1980     | 19801004   |
      # | 4-Oct-1980    | 19801004   |
      # | 04-Oct-1980   | 19801004   |
      # | 04-10-10      | 00101004   |
      # | 04-10-2010    | 20101004   |
      # | 04-1-2010     | 20100104   |
      # | 4-1-2010      | 20100104   |
      # | 4-10-2010     | 20101004   |
      # | 4-Oct-2010    | 20101004   |
      # | 04-Oct-2010   | 20101004   |
      # | 04-nov-2001   | 20011104   |
      # | 4-jAn-1999    | 19990104   |
