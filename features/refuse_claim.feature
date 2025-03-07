@javascript
Feature: Case worker rejects a claim, providing a reason

  Scenario: I refuse a claim providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/refuse'

    When I am signed in as the case worker
    And I select the claim
    When I click the link 'Claim status'
    And I click the refused radio button
    And I select the refusal reason 'Duplicate claim'
    And I select the refusal reason 'Other'
    And I enter refusal reason text 'Whatever will be will be'
    And I click update
    Then the status at top of page should be Refused
    Then message 3 contains 'Claim refused'
    Then the last message contains 'Your claim has been refused'
    Then the last message contains 'Duplicate claim'
    Then the last message contains 'Whatever will be will be'

    When I click your claims
    Then the claim I've just updated is no longer in the list

    And I eject the VCR cassette

  Scenario: I refuse a claim after a redetermination request providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a redetermination claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/refuse'

    When I am signed in as the case worker
    And I select the claim
    When I click the link 'Claim status'
    And I click the refused radio button
    And I select the refusal reason 'Incorrect trial advocate'
    And I select the refusal reason 'Other'
    And I enter refusal reason text 'Whatever I like'
    And I click update
    Then the status at top of page should be Refused
    Then the messages should not contain 'Total (inc VAT): £0.00'
    Then message 7 contains 'Claim refused'
    Then the last message contains 'Your claim has been refused'
    Then the last message contains 'Incorrect trial advocate'
    Then the last message contains 'Whatever I like'

    When I click your claims
    Then the claim I've just updated is no longer in the list

    And I eject the VCR cassette
