@javascript @no-seed
Feature: Create new advocate external users

  Scenario: External user admin creates a new advocate user
    Given I am a signed in advocate admin
    When I click the link 'Manage users'
    Then I am on the manage users page
    And I click the link 'Create a new user'
    Then I am on the new users page
    And I should see 'Add a new user to'

    And I fill in 'First name' with 'Jim'
    And I fill in 'Last name' with 'Bob'
    And I fill in 'Email' with 'jim.bob@example.com'
    And I fill in 'Email confirmation' with 'jim.bob@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'
    And I click govuk checkbox 'Admin'
    And I click govuk checkbox 'Advocate'
    And I fill in 'Supplier number' with 'ATA2B'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details should exist:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Bob | Jim | ATA2B | jim.bob@example.com | Yes |
