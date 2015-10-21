Feature: Claim messages
  Background:
    As an advocate or case worker I need to see messages that have been left
    on a claim, or to be able to add messages to the claim.

  Scenario: View messages as a case worker
    Given I am a signed in case worker
      And a claim with messages exists that I have been assigned to
     When I visit that claim's "case worker" detail page
     Then I should see the messages for that claim in chronological order

  Scenario: Leave a message as a case worker
    Given I am a signed in case worker
      And a claim with messages exists that I have been assigned to
     When I visit that claim's "case worker" detail page
      And I leave a message
     Then I should see my message at the bottom of the message list

  Scenario: View messages as an advocate
    Given I am a signed in advocate
      And I have a submitted claim with messages
     When I visit that claim's "advocate" detail page
     Then I should see the messages for that claim in chronological order

  Scenario: Leave a message as an advocate
    Given I am a signed in advocate
      And I have a submitted claim with messages
     When I visit that claim's "advocate" detail page
      And I leave a message
     Then I should see my message at the bottom of the message list
