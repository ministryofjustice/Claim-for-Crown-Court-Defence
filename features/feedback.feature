@stub_zendesk_request

Feature: A user can provide feedback and report bugs
  Scenario: An advocate is redirected to the feedback page upon sign out and is not prompted for their email
    Given I am a signed in advocate
    And I sign out
    Then I should be redirected to the feedback page
    And I should be informed that I have signed out
    Then I should not see 'What is your email address?'
    When I fill in the 'feedback' form
    Then I expect ZendeskSender to receive a description with an email
    And I see confirmation that my 'feedback' was received
    And I should be on the sign in page

  Scenario: An advocate is unable to sign in and selects to submit feedback and is prompted for their email and ignores it
    Given I have not signed in
    When I click the link 'feedback'
    Then I should see 'What is your email address?'
    When I fill in the 'feedback' form
    Then I expect ZendeskSender to receive a description without an email
    And I see confirmation that my 'feedback' was received
    And I should be on the sign in page

  Scenario: An advocate is unable to sign in and selects to submit feedback and is prompted for their email and completes it
    Given I have not signed in
    When I click the link 'feedback'
    Then I should see 'What is your email address?'
    When I fill in the 'feedback' form with email of 'test@example.com'
    Then I expect ZendeskSender to receive a description with an email
    And I see confirmation that my 'feedback' was received
    And I should be on the sign in page
 