Feature: Claim redetermination
  Background:
    As a case worker I want to be able to review claims submitted for redetermination.


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

  Scenario: Handle written reasons for claim
    Given I am a signed in case worker
      And a written reasons claim is assigned to me
     When I visit the claim's case worker detail page
     Then a written reasons notice should be present in the claim status panel
      And when I check "Written reasons submitted" and send a message
     Then the claim should be in the state previous to the written reasons request
      And the claim should no longer awaiting written reasons
