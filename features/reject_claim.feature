@no-seeding @javascript
Feature: Case worker rejects a claim, providing a reason

  Scenario: I reject a claim providing a reason

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker
    And I am signed in as the case worker

    When I select the claim
    And expand the messages section
    And I click the rejected radio button
    And I select the first rejection reason
    And I click update
    Then the status at top of page should be Rejected
    And I should see 'Reason provided:'

    When I click your claims
    Then the claim I've just updated is no longer in the list
