@javascript @no-seed
Feature: Create new external user

  Scenario: Chamber admin creates a new advocate user
    Given I am a signed in advocate admin
    When I click the link 'Manage users'
    Then I am on the manage users page
    And the page should be accessible

    When I click the link 'Create a new user'
    Then I am on the new users page
    And I should see 'Add a new user to'
    And the page should be accessible

    And the text field 'Supplier number' should be filled with ''

    Then I fill in 'First name' with 'Jim'
    And I fill in 'Last name' with 'Bob'
    And I fill in 'Email' with 'jim.bob@example.com'
    And I fill in 'Email confirmation' with 'jim.bob@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'
    And I click govuk checkbox 'Admin'

    Given I should not see 'VAT registered'
    When I click govuk checkbox 'Advocate'
    Then I should see 'VAT registered'
    And I choose govuk radio 'No' for 'VAT registered'
    And I fill in 'Supplier number' with 'BAR2A'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Bob | Jim | BAR2A | jim.bob@example.com | Yes |

  Scenario: LGFS Firm admin creates a new litigator user
    Given I am a signed in litigator admin
    When I click the link 'Manage users'
    Then I am on the manage users page
    And the page should be accessible

    When I click the link 'Create a new user'
    Then I am on the new users page
    And I should see 'Add a new user to'
    And the page should be accessible
    And the text field 'Supplier number' should be filled with ''

    Then I fill in 'First name' with 'John'
    And I fill in 'Last name' with 'Boy'
    And I fill in 'Email' with 'john.boy@example.com'
    And I fill in 'Email confirmation' with 'john.boy@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'
    And I click govuk checkbox 'Admin'
    And I click govuk checkbox 'Litigator'
    But I should not see 'VAT registered'
    And I fill in 'Supplier number' with 'SOL2A'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Boy | John | SOL2A | john.boy@example.com | Yes |

  Scenario: LGFS & AGFS Firm admin creates a new litigator-advocate user
    Given I am a signed in admin for an AGFS and LGFS firm
    When I click the link 'Manage users'
    Then I am on the manage users page
    And the page should be accessible

    When I click the link 'Create a new user'
    Then I am on the new users page
    And I should see 'Add a new user to'
    And the page should be accessible
    And the text field 'Supplier number' should be filled with '123AB'

    Then I fill in 'First name' with 'Jammy'
    And I fill in 'Last name' with 'Dodger'
    And I fill in 'Email' with 'jammy.dodger@example.com'
    And I fill in 'Email confirmation' with 'jammy.dodger@example.com'
    And I choose govuk radio 'Yes' for 'Get email notifications of caseworker messages on claims you created?'

    And I can see govuk hint 'Can create user'
    And I can see govuk hint 'Can create AGFS claims'
    And I can see govuk hint 'Can create LGFS claims'

    And I click govuk checkbox 'Admin'
    When I click govuk checkbox 'Advocate'
    Then I should not see 'VAT registered'
    And I click govuk checkbox 'Litigator'
    And I fill in 'Supplier number' with 'SAD2A'

    When I click the button 'Save'
    Then I am on the manage users page
    And I should see 'User successfully created'
    And the following user details are displayed:
      | Surname | Name | Supplier number | Email | Email notifications of messages? |
      | Dodger | Jammy | SAD2A | jammy.dodger@example.com | Yes |
