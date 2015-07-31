Feature: Claim redetermination
  Background:
    As an advocate I want to be able to re-open a claim for redetermination.
    As a case worker I want to be able to review claims submitted for redetermination.

  Scenario Outline: Redetermination button visible
    Given I am a signed in advocate
      And I have a <state> claim
     When I visit the claims's detail page
     Then I should see a button to re-open the claim for redetermination

    Examples:
      | state           |
      | paid_claim      |
      | part_paid_claim |
      | refused_claim   |

  Scenario Outline: Redetermination button NOT visible
    Given I am a signed in advocate
      And I have a <state> claim
     When I visit the claims's detail page
     Then I should not see a button to re-open the claim for redetermination

    Examples:
      | state                           |
      | draft_claim                     |
      | submitted_claim                 |
      | allocated_claim                 |
      | awaiting_further_info_claim     |
      | awaiting_info_from_court_claim  |
      | rejected_claim                  |
      | redetermination_claim           |
      | completed_claim                 |


  Scenario: Re-open claim for redetermination
    Given I am a signed in advocate
      And I have a paid_claim claim
     When I visit the claims's detail page
      And I click on "Request redetermination"
     Then the claim should be in the redetermination state
      And a notice should be present in the claim status panel

  Scenario Outline: Handle redetermination claims
    Given I am a signed in case worker
      And a redetermined claim is assigned to me
     When I visit the claim's case worker detail page
     Then a notice should be present in the claim status panel
      And when I select a state of "<form_state>" and update the claim
     Then the claim should be in the "<state>" state

    Examples:
      | form_state                | state                    |
      | Part paid                 | part_paid                |
      | Paid in full              | paid                     |
      | Rejected                  | rejected                 |
      | Refused                   | refused                  |
      | Awaiting info from court  | awaiting_info_from_court |
