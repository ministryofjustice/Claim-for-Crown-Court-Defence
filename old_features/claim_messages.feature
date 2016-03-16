Feature: Claim messages
  Background:
    As an advocate or case worker I need to see messages that have been left
    on a claim, or to be able to add messages to the claim.

  Scenario: View messages as a case worker
    Given I am a signed in case worker
      And a claim with messages exists that I have been assigned to
     When I visit that claim's "case worker" detail page
      And I expand the accordion
     Then I should see the messages for that claim in chronological order

  Scenario: Leave a message as a case worker
    Given I am a signed in case worker
      And a claim with messages exists that I have been assigned to
     When I visit that claim's "case worker" detail page
      And I expand the accordion
      And I leave a message
     Then I should see my message at the bottom of the message list

  Scenario: Only updates to state are tracked by papertrail
    Given I am a signed in advocate
      And There are case types in place
      And I am on the new claim page
      And I fill in the claim details
      And I save to drafts
    When I edit the claim and save to draft
      And I view the claim
      And I expand the accordion
    Then I should not see any dates in the message history field
      And I should see 'no messages found' in the claim history

  Scenario: View messages as an advocate
    Given I am a signed in advocate
      And I have a submitted claim with messages
     When I visit that claim's "advocate" detail page
      And I expand the accordion
     Then I should see the messages for that claim in chronological order

  Scenario: Leave a message as an advocate
    Given I am a signed in advocate
      And I have a submitted claim with messages
     When I visit that claim's "advocate" detail page
      And I expand the accordion
      And I leave a message
     Then I should see my message at the bottom of the message list

Scenario Outline: Advocate user can see the correct controls on initial page load
  Given I am a signed in advocate
    And I have 1 <state> claim
   When I visit that claim's "advocate" detail page
    And I expand the accordion
   Then I <radio_button_expectation> see the redetermination button
    And I <radio_button_expectation> see the request written reason button
    And I <msg_control_expectation> see the controls to send messages

    Examples:
      | state                       | radio_button_expectation  | msg_control_expectation |
      | draft                       | should not                | should not              |
      | submitted                   | should not                | should                  |
      | allocated                   | should not                | should                  |
      | authorised                  | should                    | should not              |
      | part_authorised             | should                    | should not              |
      | rejected                    | should not                | should not              |
      | refused                     | should                    | should not              |
      | awaiting_written_reasons    | should not                | should                  |
      | redetermination             | should not                | should                  |
      | archived_pending_delete     | should not                | should not              |

@javascript @webmock_allow_localhost_connect
Scenario Outline: Advocate clicking on messages radio button and seeing the controls
  Given I am a signed in advocate
    And I have 1 <state> claim
   When I visit that claim's "advocate" detail page
    And I expand the accordion
    And click on <radio_button> option
   Then I <msg_control_expectation> see the controls to send messages
    And I can send a message
    And I should see my message at the bottom of the message list
    And the claim should be in the "<next_claim_state>" state
    And the claim should no longer have case workers assigned

    Examples:
      | state              | radio_button               | msg_control_expectation | next_claim_state          |
      | authorised         | Apply for redetermination  | should                  | redetermination           |
      | authorised         | Request written reasons    | should                  | awaiting_written_reasons  |
      | part_authorised    | Apply for redetermination  | should                  | redetermination           |
      | part_authorised    | Request written reasons    | should                  | awaiting_written_reasons  |
      | refused            | Apply for redetermination  | should                  | redetermination           |
      | refused            | Request written reasons    | should                  | awaiting_written_reasons  |

@javascript @webmock_allow_localhost_connect
Scenario Outline: Advocate clicking seeing messages control and can send emails
  Given I am a signed in advocate
    And I have 1 <state> claim
   When I visit that claim's "advocate" detail page
   Then I expand the accordion
    And I <msg_control_expectation> see the controls to send messages
    And I can send a message
    And I should see my message at the bottom of the message list

    Examples:
      | state                      | msg_control_expectation |
      | submitted                  | should                  |
      | allocated                  | should                  |
      | awaiting_written_reasons   | should                  |
      | redetermination            | should                  |

@javascript @webmock_allow_localhost_connect
Scenario Outline: Advocate admin user can see the correct controls on first page load
  Given I am a signed in advocate admin
    And I have 1 <state> claim
   When I visit that claim's "advocate" detail page
    And I expand the accordion
   Then I <radio_button_expectation> see the redetermination button
    And I <radio_button_expectation> see the request written reason button
    And I <msg_control_expectation> see the controls to send messages

    Examples:
      | state                       | radio_button_expectation  | msg_control_expectation |
      | draft                       | should not                | should not              |
      | submitted                   | should not                | should                  |
      | allocated                   | should not                | should                  |
      | authorised                  | should                    | should not              |
      | part_authorised             | should                    | should not              |
      | rejected                    | should not                | should not              |
      | refused                     | should                    | should not              |
      | awaiting_written_reasons    | should not                | should                  |
      | redetermination             | should not                | should                  |
      | archived_pending_delete     | should not                | should not              |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Advocate admin user clicking on messages radio button and seeing the controls
    Given I am a signed in advocate admin
      And I have 1 <state> claim
     When I visit that claim's "advocate" detail page
      And I expand the accordion
      And click on <radio_button> option
     Then I <msg_control_expectation> see the controls to send messages
      And I can send a message

    Examples:
      | state                       | radio_button                 | msg_control_expectation |
      | authorised                  | Apply for redetermination  | should                  |
      | authorised                  | Request written reasons    | should                  |
      | part_authorised             | Apply for redetermination  | should                  |
      | part_authorised             | Request written reasons    | should                  |
      | refused                     | Apply for redetermination  | should                  |
      | refused                     | Request written reasons    | should                  |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Advocate clicking seeing messages control and can send emails
    Given I am a signed in advocate admin
      And I have 1 <state> claim
     When I visit that claim's "advocate" detail page
     Then I expand the accordion
      And I <msg_control_expectation> see the controls to send messages
      And I can send a message
      And I should see my message at the bottom of the message list

      Examples:
        | state                      | msg_control_expectation |
        | submitted                  | should                  |
        | allocated                  | should                  |
        | awaiting_written_reasons   | should                  |
        | redetermination            | should                  |
