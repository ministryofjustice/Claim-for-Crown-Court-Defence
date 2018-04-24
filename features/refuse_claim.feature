@javascript
Feature: Case worker rejects a claim, providing a reason

  Scenario: I refuse a claim providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/refuse'

    When I am signed in as the case worker
    And the reject refuse messaging feature is released
    And I select the claim
    And I click the refused radio button
    And I select the first refusal reason
    And I click update
    Then the status at top of page should be Refused
    Then the third message contains 'Claim refused'
    Then the last message contains 'Your claim has been refused'

    When I click your claims
    Then the claim I've just updated is no longer in the list

    And I eject the VCR cassette
