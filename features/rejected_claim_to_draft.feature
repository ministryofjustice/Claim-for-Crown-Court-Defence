Feature: Rejected claim to new draft
  Background:
    As an advocate I want to be able to re-submit rejected claims by creating a
    new draft.

    Given I am a signed in advocate

    Scenario Outline: No link to create draft from non-rejected claim
      Given I am on the detail page for a <state> claim
       Then I should not see the "Create draft and resubmit" link

      Examples:
        | state                      |
        | "submitted"                |
        | "allocated"                |
        | "refused"                  |
        | "part_authorised"          |
        | "authorised"               |
        | "draft"                    |
        | "redetermination"          |
        | "awaiting_written_reasons" |

    Scenario: Create draft from rejected claim
      Given I am on the detail page for a rejected claim with case number 'T12345678'
       When I click "Create draft and resubmit"
       Then I should be redirected to the edit page of a draft claim
        And the draft claim should have case number 'T12345678'
