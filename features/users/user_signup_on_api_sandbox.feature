@javascript @no-seed @focus
Feature: User signup on api-sandbox

  @on-api-sandbox
  Scenario: User signs up on the api-sandbox
    Given I visit "/"
    Then I should see link 'API Sign up and documentation'
    And I should see link 'software vendor terms and conditions'

    When I click the link 'API Sign up and documentation'
    Then I am on the api landing page

    When I click the link 'complete a short registration form'
    Then I am on the new user sign up page
    And the page should be accessible
    And I should see 'Our software vendor terms and conditions contain important information you must agree to'

    When I click the first 'software vendor terms and conditions' link
    Then I am on the software vendor terms and conditions page
    And I go back

    When I click govuk checkbox 'I agree to the terms and conditions'
    Then I fill in 'First name' with 'Jim'
    And I fill in 'Last name' with 'Bob'
    And I fill in 'Email' with 'jim.bob@example.com'
    And I fill in 'Email confirmation' with 'jim.bob@example.com'
    And I fill in 'Password' with 'my-password'
    And I fill in 'Password confirmation' with 'my-password'
    And I save and open screenshot
    And I click the button 'Sign up'
    And I save and open screenshot

    Then My new claim should be displayed
    And I should see 'Welcome! You have signed up successfully.'
