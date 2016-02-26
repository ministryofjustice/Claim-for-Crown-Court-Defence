@stub_zendesk_request

Feature: A user can provide feedback and report bugs
  Background:
    Given I am a signed in advocate

  Scenario: An advocate provides feedback on their experience of the service
    Given I click 'feedback'
     When I fill in the 'feedback' form
     Then I see confirmation that my 'feedback' was received

  Scenario: An advocate is redirected to the feedback page upon sign out
    Given I sign out
     Then I should be redirected to the feedback page
      And I should be informed that I have signed out
     When I fill in the 'feedback' form
     Then I see confirmation that my 'feedback' was received
      And I should be on the sign in page

  Scenario: An advocate submits a bug report
    Given I click 'report a fault here.'
     When I fill in the 'bug report' form
     Then I see confirmation that my 'bug report' was received
