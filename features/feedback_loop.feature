Feature: A user can provide feedback and report bugs

@stub_zendesk_request
Scenario: An advocate provides feedback on their experience of the service
  Given I am a signed in advocate
  When I click 'feedback'
    And I fill in the 'feedback' form
  Then I see confirmation that my 'feedback' was received

@stub_zendesk_request
Scenario: An advocate submits a bug report
  Given I am a signed in advocate
  When I click 'report a fault here.'
    And I fill in the 'bug report' form
  Then I see confirmation that my 'bug report' was received
