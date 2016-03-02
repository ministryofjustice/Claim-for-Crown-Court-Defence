@api-sandbox
Feature: API Sandbox

Background:
  The API sandbox environment should provide conditional and easy access to the
  API documentation and sign up for software vendors

Scenario: Sign in page for NOT API sandbox
    Given I am not on the API sandbox
     When I visit the user sign in page
     Then I should not see a link to the API documentation

  Scenario: Sign in page for API sandbox
    Given I am on the API sandbox
     When I visit the user sign in page
     Then I should see a link to the API sign up and documentation
     When I click on the API Sign up and Documentation link
     Then I should be directed to the API landing page

  @vendor
  Scenario: API documentation available from dashboard
    Given I am on the API sandbox
      And I am a signed in advocate
     When I visit the advocates dashboard
     Then I should see a link to the API documentation

  @vendor
  Scenario: API documentation not available from dashboard
    Given I am not on the API sandbox
      And I am a signed in advocate
     When I visit the advocates dashboard
     Then I should not see a link to the API documentation

  @vendor
  Scenario: Interactive API documentation (swagger)
    Given I am on the API sandbox
      And I am a signed in advocate
     When I visit the Interactive API Documentation page
      And I should see the advocates correct working primary navigation
      And I visit the Interactive API Documentation page
     Then It should be styled to ADP GDS standards
