@javascript @no-seed
Feature: Create new and update existing external users

  Scenario: Chamber admin creates and updates an advocate user
    Given I am a signed in advocate admin
    When I click the link 'Manage users'
    Then I am on the manage users page
    And the page should be accessible

    When I click the link 'Create a new user'
    Then I am on the new user page
    And I should see 'Add a new user to'
    And the page should be accessible skipping 'aria-allowed-attr'

    Then I fill in 'First name' with 'Jim'
    And I fill in 'Last name' with 'Bob'
    And I fill in 'Email' with 'jim.bob@example.com'
    And I fill in 'Email confirmation' with 'jim.bob@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'
    And I click govuk checkbox 'Admin'

    Given I should not see 'VAT registered'
    And I should not see 'Supplier number'
    When I click govuk checkbox 'Advocate'
    And the page should be accessible skipping 'aria-allowed-attr'
    Then I should see 'VAT registered'
    And I choose govuk radio 'No' for 'VAT registered'
    Then I should see 'Supplier number'
    And I fill in 'Supplier number' with 'BAR2A'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Bob | Jim | BAR2A | jim.bob@example.com | Yes |

    When I click the link 'Edit' for user 'jim.bob@example.com' on the manage users page
    Then I am on the edit user page
    And the page should be accessible skipping 'aria-allowed-attr'

    When I fill in 'First name' with 'John'
    And I fill in 'Email' with 'john.bob@example.com'
    And I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully updated'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Bob | John | BAR2A | john.bob@example.com | Yes |

  Scenario: LGFS Firm admin creates a new litigator user
    Given I am a signed in litigator admin
    When I click the link 'Manage users'
    Then I am on the manage users page
    And the page should be accessible

    When I click the link 'Create a new user'
    Then I am on the new user page
    And I should see 'Add a new user to'
    And the page should be accessible

    Then I fill in 'First name' with 'John'
    And I fill in 'Last name' with 'Boy'
    And I fill in 'Email' with 'john.boy@example.com'
    And I fill in 'Email confirmation' with 'john.boy@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'
    And I click govuk checkbox 'Admin'
    And I click govuk checkbox 'Litigator'
    But I should not see 'VAT registered'
    And I should not see 'Supplier number'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Boy | John | - | john.boy@example.com | Yes |

  Scenario: LGFS & AGFS Firm admin creates a new litigator-advocate user
    Given I am a signed in admin for an AGFS and LGFS firm
    When I click the link 'Manage users'
    Then I am on the manage users page
    And the page should be accessible

    When I click the link 'Create a new user'
    Then I am on the new user page
    And I should see 'Add a new user to'
    And the page should be accessible

    Then I fill in 'First name' with 'Jammy'
    And I fill in 'Last name' with 'Dodger'
    And I fill in 'Email' with 'jammy.dodger@example.com'
    And I fill in 'Email confirmation' with 'jammy.dodger@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'

    Given I click govuk checkbox 'Admin'
    And I click govuk checkbox 'Advocate'
    But I should not see 'VAT registered'
    And I should not see 'Supplier number'
    And I click govuk checkbox 'Litigator'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Dodger | Jammy | 123AB | jammy.dodger@example.com | Yes |
