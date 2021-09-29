@javascript @no-seed
Feature: A user can provide feedback and bug report

  @survey_monkey_vcr
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
    Given I insert the VCR cassette 'features/feedback/survey_monkey'
    And I click the button 'Send'

    Then I see confirmation that my 'feedback' was received
    And I should be on the sign in page

    Then I eject the VCR cassette

  @stub_zendesk_request
  Scenario: A user can successfully submit a bug report
    Given I visit "/"
    When I click the link 'report a fault'
    Then I should see a page title "Bug report"
    Then the page should be accessible

    And I fill in 'What you were doing when the fault occurred?' with 'Filling in a new claim form'
    And I fill in 'What went wrong?' with 'Something went wrong'
    And I see confirmation that my 'bug report' was received
    Then I should be on the sign in page
