@javascript @no-seed @vat-seeds
Feature: Super admin can enable and disable users

  Scenario: Super admin can disable user

    Given an external provider exists with first name 'John' and last name 'Doe'
    And I am a signed in super admin
    When I click the link 'Providers'
    Then I should be on the provider index page
    And the page should be accessible

    When I click the link 'Manage users in provider'
    Then I should be on the provider manager user index page
    And the page should be accessible

    When I click the link 'John Doe'
    Then I should be on the provider manager user show page
    And the page should be accessible
    And I should see 'Live, Enabled'
    And I should see link 'Disable account'

    When I click the link 'Disable account'
    Then I should be on the provider manager user change availability page
    And the page should be accessible
    And I should see 'Are you sure you want to disable John Doe?'
    And I should see button 'Disable account'
    And I should see link 'Cancel'

    When I click the link 'Cancel'
    Then I should be on the provider manager user show page

    When I click the link 'Disable account'
    Then I should be on the provider manager user change availability page

    When I click the button 'Disable account'
    Then I should be on the provider manager user show page
    And I should see 'Live, Disabled'
    And I should see link 'Enable account'

  Scenario: Super admin can enable user

    Given a disabled external provider exists with first name 'John' and last name 'Doe'
    And I am a signed in super admin
    When I click the link 'Providers'
    Then I should be on the provider index page
    And the page should be accessible

    When I click the link 'Manage users in provider'
    Then I should be on the provider manager user index page
    And the page should be accessible

    When I click the link 'John Doe'
    Then I should be on the provider manager user show page
    And the page should be accessible
    And I should see 'Live, Disabled'
    And I should see link 'Enable account'

    When I click the link 'Enable account'
    Then I should be on the provider manager user change availability page
    And the page should be accessible
    And I should see 'Are you sure you want to enable John Doe?'
    And I should see button 'Enable account'
    And I should see link 'Cancel'

    When I click the link 'Cancel'
    Then I should be on the provider manager user show page

    When I click the link 'Enable account'
    Then I should be on the provider manager user change availability page

    When I click the button 'Enable account'
    Then I should be on the provider manager user show page
    And I should see 'Live, Enabled'
    And I should see link 'Disable account'

  # Provider admin logged in...
  Scenario: Inactive users with live account
    And an "advocate" user account exists
    And the advocate is disabled
    Given I am a signed in advocate admin
    And both users belong to the same firm
    When I click the link 'Manage users'
    Then I am on the manage users page
    And I should see 'Inactive'
    And I should see link 'Edit'
    And I should see link 'Delete'

  Scenario: Active user with live account
    Given an "advocate" user account exists
    And the advocate is enabled
    Given I am a signed in advocate admin
    And both users belong to the same firm
    When I click the link 'Manage users'
    Then I am on the manage users page
    And I should not see 'Inactive'
    And I should see link 'Edit'
    And I should see link 'Delete'

  Scenario: Active users with deleted account
    Given an "advocate" user account exists
    And the advocate is enabled
    And the advocate user account is deleted
    Given I am a signed in advocate admin
    And both users belong to the same firm
    When I click the link 'Manage users'
    Then I am on the manage users page
    And I should see 'Inactive'

  Scenario: Inactive users with deleted account
    Given an "advocate" user account exists
    And the advocate is disabled
    And the advocate user account is deleted
    Given I am a signed in advocate admin
    And both users belong to the same firm
    When I click the link 'Manage users'
    Then I am on the manage users page
    And I should see 'Inactive'

  Scenario: Superadmin can identify disabled users
    Given I am a signed in super admin
    And an "advocate" user account exists
    And the advocate is disabled
    When I click the link 'Providers'
    And I click the link 'Manage users in provider'
    Then I should be on the provider manager user index page
    And I should see 'Inactive'
