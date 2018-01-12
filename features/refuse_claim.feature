@javascript
Feature: Case worker rejects a claim, providing a reason

  Scenario: I refuse a claim providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/reject'

    When I am signed in as the case worker
    And I select the claim
    And expand the messages section
    And I click the refused radio button
    And I select the first refusal reason
    And I click update
    Then the status at top of page should be Refused
    And I should see 'Reason provided:'

    When I click your claims
    Then the claim I've just updated is no longer in the list
