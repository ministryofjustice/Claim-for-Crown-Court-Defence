@javascript @no-seed
Feature: A user can provide a bug report

  @stub_feedback_success
  Scenario: A logged in user can successfully submit a bug report
    Given I am a signed in advocate admin
    And I am on the 'Your claims' page

    When I click the link 'report a fault'
    Then I should see a page title "Bug report"
    And I should not see 'What is your email address? (Optional)'

    When I fill in 'What you were doing when the fault occurred?' with 'Filling in a new claim form'
    And I fill in 'What went wrong?' with 'Something went wrong'
    And I click the button 'Send'

    Then I see confirmation that my 'bug report' was received
    And I should be on the your claims page

  @stub_feedback_success
  Scenario: A logged out user can successfully submit a bug report
    Given I visit "/"
    When I click the link 'report a fault'
    Then I should see a page title "Bug report"
    And the page should be accessible

    When I fill in 'What you were doing when the fault occurred?' with 'Filling in a new claim form'
    And I fill in 'What went wrong?' with 'Something went wrong'
    And I fill in 'What is your email address? (Optional)' with 'joe.bloggs@example.com'
    And I click the button 'Send'

    Then I see confirmation that my 'bug report' was received
    And I should be on the sign in page

  @stub_feedback_failure
  Scenario: A user unsuccessfully submits a bug report
    Given I visit "/"
    When I click the link 'report a fault'
    Then I should see a page title "Bug report"
    And the page should be accessible

    When I fill in 'What you were doing when the fault occurred?' with 'Filling in a new claim form'
    And I fill in 'What went wrong?' with 'Something went wrong'
    And I fill in 'What is your email address? (Optional)' with 'joe.bloggs@example.com'
    And I click the button 'Send'

    Then I see a warning that my bug report was not submitted successfully
    And I should be on the bug report page
