@no-seeding @javascript
Feature: Case worker fully authorises claim

  Scenario: I fully authorise a claim

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker
    And I am signed in as the case worker

    When I select the claim
    And expand the messages section
    And fill out the Fees Total authorised by Laa with the amount of fees claimed
    And do the same with expenses
    And I click the authorised radio button
    And I click update
    Then the status at top of page should be Authorised

    When I click your claims
    Then the claim I've just authorised is no longer in the list
