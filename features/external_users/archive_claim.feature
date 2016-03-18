@advocate @spec
Feature: Archive claim
  Background:
    As an advocate I want to be able to archive my completed claims

    Given I am a signed in advocate

    Scenario Outline: Archive claims in valid states
      Given I am on the detail page for a <state> claim
       Then I should see the archive button
       When I click on the archive button
       Then the claim should be archived
        And I should see the claim on the archive page

      Examples: A claim in a specific state
        | state                      |
        | "refused"                  |
        | "part_authorised"          |
        | "rejected"                 |
        | "authorised"               |

    Scenario Outline: Archive claims in valid states
      Given I am on the detail page for a <state> claim
       Then I should not see the archive button
        And I should not see the claim on the archive page

      Examples: A claim in a specific state
        | state                      |
        | "allocated"                |
        | "awaiting_written_reasons" |
        | "redetermination"          |
        | "draft"                    |
