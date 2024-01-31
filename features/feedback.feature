@javascript @no-seed
Feature: A user can provide feedback
  @stub_survey_monkey_feedback_success
  Scenario: A user can successfully submit feedback
    Given I visit "/"
    And Zendesk Feedback is 'Disabled'
    When I click the link 'Provide feedback'
    Then I should see a page title "Help us improve this service"
    Then the page should be accessible skipping 'aria-allowed-attr'

    And I choose govuk radio 'Yes' for 'Were you able to complete the tasks you aimed to on Claim for crown court defence today?'
    And I choose govuk radio 'Very satisfied' for 'How satisfied have you been in your experience of Claim for crown court defence today?'
    And I fill in 'Tell us about your experience of using the service today' with 'This is great!'
    And I click govuk checkbox 'Other (please specify)'
    And I fill in 'Enter your comment' with 'Something Else'
    And I click the button 'Send'

    Then I see confirmation that my 'feedback' was received
    And I should be on the sign in page

  @stub_zendesk_feedback_success
  Scenario: A user can successfully submit feedback
    Given I visit "/"
    And Zendesk Feedback is 'Enabled'
    When I click the link 'Provide feedback'
    Then I should see a page title "Help us improve this service"
    Then the page should be accessible skipping 'aria-allowed-attr'

    And I choose govuk radio 'Yes' for 'Were you able to complete the tasks you aimed to on Claim for crown court defence today?'
    And I choose govuk radio 'Very satisfied' for 'How satisfied have you been in your experience of Claim for crown court defence today?'
    And I fill in 'Tell us about your experience of using the service today' with 'This is great!'
    And I click govuk checkbox 'Other (please specify)'
    And I fill in 'Enter your comment' with 'Something Else'
    And I click the button 'Send'

    Then I see confirmation that my 'feedback' was received
    And I should be on the sign in page

  @stub_survey_monkey_feedback_failure
  Scenario: A user receives notification of a failure to submit feedback
    Given I visit "/"
    And Zendesk Feedback is 'Disabled'
    When I click the link 'Provide feedback'
    Then I should see a page title "Help us improve this service"
    Then the page should be accessible skipping 'aria-allowed-attr'

    And I choose govuk radio 'Yes' for 'Were you able to complete the tasks you aimed to on Claim for crown court defence today?'
    And I choose govuk radio 'Very satisfied' for 'How satisfied have you been in your experience of Claim for crown court defence today?'
    And I fill in 'Tell us about your experience of using the service today' with 'This is great!'
    And I click govuk checkbox 'Other (please specify)'
    And I fill in 'Enter your comment' with 'Something Else'
    And I click the button 'Send'

    Then I see a warning that my feedback was not submitted successfully
    And I should be on the feedback page

  @stub_zendesk_feedback_failure
  Scenario: A user receives notification of a failure to submit feedback
    Given I visit "/"
    And Zendesk Feedback is 'Enabled'
    When I click the link 'Provide feedback'
    Then I should see a page title "Help us improve this service"
    Then the page should be accessible skipping 'aria-allowed-attr'

    And I choose govuk radio 'Yes' for 'Were you able to complete the tasks you aimed to on Claim for crown court defence today?'
    And I choose govuk radio 'Very satisfied' for 'How satisfied have you been in your experience of Claim for crown court defence today?'
    And I fill in 'Tell us about your experience of using the service today' with 'This is great!'
    And I click govuk checkbox 'Other (please specify)'
    And I fill in 'Enter your comment' with 'Something Else'
    And I click the button 'Send'

    Then I see a warning that my feedback was not submitted successfully
    And I should be on the feedback page
