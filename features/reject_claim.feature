@javascript
Feature: Case worker rejects a claim, providing a reason

  Scenario: I reject a claim providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/reject'

    When I am signed in as the case worker
    And I select the claim
    When I click the link 'Claim status'
    And I click the rejected radio button
    And I select the rejection reason 'No indictment attached'
    And I select the rejection reason 'Other'
    And I enter rejection reason text 'Whatever will be will be'
    Then the page should be accessible
    And I click update
    Then the status at top of page should be Rejected
    Then caseworkers claim message 3 contains 'Claim rejected'
    Then the caseworkers last message contains 'Your claim has been rejected'
    Then the caseworkers last message contains 'No indictment attached'
    Then the caseworkers last message contains 'Whatever will be will be'
    Then the page should be accessible

    When I click your claims
    Then the claim I've just updated is no longer in the list

    And I eject the VCR cassette
