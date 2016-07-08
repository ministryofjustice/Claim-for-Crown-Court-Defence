@javascript
Feature: Case worker messages advocate and advocate responds

  Scenario: I message advocate and advocate responds

    Given a "case worker" user account exists
    And an "advocate" user account exists
    And there is a claim allocated to the case worker
    And I am signed in as the case worker

    When I select the claim
    And expand the messages section
    And I send a message 'More information please'
    And I sign out as caseworker
    And I sign in as the advocate
    Then the claim should be displayed with a status of 'Allocated'
    And it is displaying 'View (1 new)' in the messages column

    When I open up the claim
    And I expand messages
    Then the message 'More information please' from the caseworker should be visible

    When I enter a message 'Commital bundle provided'
    And I upload a file
    And I click send
    And I sign out as advocate
    And I sign in as the case worker
    Then the claim should be visible with 1 new message

    When I open the claim
    And I expand messages
    Then the response and uploaded file should be visible
