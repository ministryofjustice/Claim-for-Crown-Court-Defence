@stub_zendesk_request @javascript
Feature: A user can provide feedback
  Scenario: A user can successfully submit a feedback
    Given I visit "/"
    When I click the link 'Provide feedback'
    Then I should see a page title "Help us improve this service"
    Then the page should be accessible skipping 'aria-allowed-attr'

    And I choose govuk radio 'Yes' for 'Were you able to complete the tasks you aimed to on Claim for crown court defence today?'
    And I choose govuk radio 'Very satisfied' for 'How satisfied have you been in your experience of Claim for crown court defence today?'
    And I fill in 'Tell us about your experience of using the service today' with 'This is great!'
    And I click govuk checkbox 'Other (please specify)'
    And I fill in 'Enter your comment' with 'Something Else'
    And I click the button 'Send'

    And I see confirmation that my 'feedback' was received
    Then I should be on the sign in page