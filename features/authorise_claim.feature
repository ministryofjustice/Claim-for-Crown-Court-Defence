@javascript
Feature: Case worker fully authorises claim

  Scenario: I fully authorise a claim

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'

    And I insert the VCR cassette 'features/case_workers/claims/authorise'

    When I am signed in as the case worker
    And I select the claim
    Then I should see a page title "View the claim details"
    And I fill in 'Fees' with '1.23'
    And I fill in 'Expenses' with '2.34'
    And I choose govuk radio 'Authorised' for 'Update the claim status'
    And I click update
    Then the status at top of page should be Authorised
    Then the page should be accessible

    When I click your claims
    Then the claim I've just updated is no longer in the list

    And I eject the VCR cassette
