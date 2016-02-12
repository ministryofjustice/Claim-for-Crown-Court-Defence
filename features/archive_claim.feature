Feature: Archive claim
  Background:
    As an advocate I want to be able to archive my completed claims

    Given I am a signed in advocate

    Scenario Outline: Archive claims in valid states
      Given I am on the detail page for a <state> claim
       Then I should see the archive button
       When I click on the archive button
        Then I should see the claim on the archive page

      Examples:
        | state                      |
        | "refused"                  |
        | "part_authorised"          |
        | "rejected"                 |
        | "authorised"               |

    Scenario Outline: Archive claims in valid states
      Given I am on the detail page for a <state> claim
       Then I should not see the archive button

      Examples:
        | state                      |
        | "allocated"                |
        | "awaiting_written_reasons" |
        | "redetermination"          |
        | "draft"                    |
