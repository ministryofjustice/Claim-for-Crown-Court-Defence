@javascript
Feature: Case worker viewing and dismissing a data injection error

  Scenario: I dismiss a data injection error

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'
    And the claim "A20161234" has an injection error

    And I insert the VCR cassette 'features/case_workers/claims/injection_error'

    When I am signed in as the case worker
    And I select the claim
    Then The injection error summary is visible
    # And I click the dismiss injection error button
    # Then the injection error disappears

    # When I click your claims
    # Then the claim I've just updated no longer has an error in the list

    And I eject the VCR cassette
