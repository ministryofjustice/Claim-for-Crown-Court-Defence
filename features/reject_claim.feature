@javascript
Feature: Case worker rejects a claim, providing a reason

  Scenario: I reject a claim providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/reject'

    When I am signed in as the case worker
    And the reject refuse messaging feature is released
    And I select the claim
    And I choose govuk radio 'Rejected' for 'Update the claim status'
    And I click govuk checkbox 'No indictment attached'
    And I click govuk checkbox 'Other'
    And I fill in 'Reason text' with 'Whatever will be will be'
    Then the page should be accessible skipping 'aria-allowed-attr'
    And I click update
    Then the status at top of page should be Rejected
    Then message 3 contains 'Claim rejected'
    Then the last message contains 'Your claim has been rejected'
    Then the last message contains 'No indictment attached'
    Then the last message contains 'Whatever will be will be'
    Then the page should be accessible

    When I click your claims
    Then the claim I've just updated is no longer in the list

    And I eject the VCR cassette
