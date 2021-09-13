@stub_zendesk_request
Feature: A user can provide feedback and report bugs
  Scenario: A user can successfully submit a feedback
    Given I visit "/"
    When I click the link 'Provide feedback'
    Then the page should be accessible
    When I fill in the 'feedback' form
    And I see confirmation that my 'feedback' was received
    Then I should be on the sign in page