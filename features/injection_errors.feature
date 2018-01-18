@javascript
Feature: Case worker viewing and dismissing a data injection error

  Scenario: I dismiss a data injection error

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker with case number 'A20161234'
    And the claim "A20161234" has an injection error

    And I insert the VCR cassette 'features/case_workers/claims/injection_error'

    When I am signed in as the case worker
    And I click your claims
    Then claim "A20161234" does have an injection error visible

    And I select claim "A20161234"
    Then the injection error summary is visible
    And there are "2" injection error messages

    When I dismiss the injection error
    Then the injection error summary is not visible

    When I click your claims
    Then claim "A20161234" does not have an injection error visible

    And I eject the VCR cassette
