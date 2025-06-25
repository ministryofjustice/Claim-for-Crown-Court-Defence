@javascript @no-seed
Feature: This feature runs first to sanitize the database.

  Scenario: Logged out I see the login page. Silly test will do the magic.
    Given I visit "/"
    Then I should see 'Sign in'
    Then I should see a page title "Sign in to claim for Crown Court defence"
    Then the page should be accessible
