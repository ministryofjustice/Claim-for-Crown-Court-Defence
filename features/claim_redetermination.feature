Feature: Claim redetermination
  Background:
    As an advocate I want to be able to re-open a claim for redetermination.
    As a case worker I want to be able to review claims submitted for redetermination.

  Scenario Outline: Redetermination control visible
    Given I am a signed in advocate
      And I have a <state> claim
     When I visit the claims's detail page
     Then I should see a control in the messages section to request a redetermination

    Examples:
      | state                 |
      | authorised_claim      |
      | part_authorised_claim |
      | refused_claim         |

  Scenario Outline: Redetermination control NOT visible
    Given I am a signed in advocate
      And I have a <state> claim
     When I visit the claims's detail page
     Then I should not see a control in the messages section to request a redetermination

    Examples:
      | state                     |
      | draft                     |
      | submitted                 |
      | allocated                 |
      | rejected                  |
      | redetermination           |

  Scenario: Re-open claim for redetermination
    Given I am a signed in advocate
      And I have a authorised_claim claim
      And the claim has a case worker assigned to it
     When I visit the claims's detail page
      And I select "Apply for redetermination" and send a message
     Then the claim should be in the "redetermination" state
      And the claim should no longer have case workers assigned
      And a redetermination notice should be present in the claim status panel

  Scenario: Allow entry of redetermination values
    Given I am a signed in case worker
      And a redetermined claim is assigned to me
      And I visit the claim's case worker detail page
     Then a form should be visible for me to enter the redetermination amounts
     When I enter redetermination amounts
     Then There should be no form to enter redetermination amounts
      And The redetermination I just entered should be visible

  Scenario Outline: Handle redetermination claims
    Given I am a signed in case worker
      And a redetermined claim is assigned to me
     When I visit the claim's case worker detail page
     Then a redetermination notice should be present in the claim status panel
      And when I select a state of "<form_state>" and update the claim
     Then the claim should be in the "<state>" state
      And the claim should no longer be open for redetermination

    Examples:
      | form_state                | state                    |
      | Part authorised           | part_authorised          |
      | Authorised                | authorised               |
      | Rejected                  | rejected                 |
      | Refused                   | refused                  |

  Scenario: Request written reasons for claim
    Given I am a signed in advocate
      And I have a authorised_claim claim
      And the claim has a case worker assigned to it
     When I visit the claims's detail page
      And I select "Request written reasons" and send a message
     Then the claim should be in the "awaiting_written_reasons" state
      And the claim should no longer have case workers assigned
      And a written reasons notice should be present in the claim status panel

  Scenario: Handle written reasons for claim
    Given I am a signed in case worker
      And a written reasons claim is assigned to me
     When I visit the claim's case worker detail page
     Then a written reasons notice should be present in the claim status panel
      And when I check "Written reasons submitted" and send a message
     Then the claim should be in the state previous to the written reasons request
      And the claim should no longer awaiting written reasons
