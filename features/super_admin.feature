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
    And I should see 'Live'
    And I should see link 'Disable'

    When I click the link 'Disable'
    Then I should be on the provider manager user confirmation page
    And the page should be accessible
    And I should see 'Are you sure you want to disable John Doe'

    When I click the link 'Cancel'
    Then I should be on the provider manager user show page
    And the page should be accessible
    And I should see 'Live'
    And I should see link 'Disable'

    When I click the link 'Disable'
    Then I should be on the provider manager user confirmation page
    And the page should be accessible
    And I should see 'Are you sure you want to disable John Doe'
    And I should see link 'Disable'

    When I click the link 'Disable'
    Then I should be on the provider manager user show page
    And the page should be accessible
    And I should see 'Inactive'
    And I should see link 'Enable'

Scenario: Super admin can enable user

    Given a disable external provider exists with first name 'John' and last name 'Doe'
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
    And I should see 'Inactive'
    And I should see link 'Enable'

    When I click the link 'Enable'
    Then I should be on the provider manager user confirmation page
    And the page should be accessible
    And I should see 'Are you sure you want to enable John Doe'

    When I click the link 'Cancel'
    Then I should be on the provider manager user show page
    And the page should be accessible
    And I should see 'Inactive'
    And I should see link 'Enable'

    When I click the link 'Enable'
    Then I should be on the provider manager user confirmation page
    And the page should be accessible
    And I should see 'Are you sure you want to enable John Doe'
    And I should see link 'Enable'

    When I click the link 'Enable'
    Then I should be on the provider manager user show page
    And the page should be accessible
    And I should see 'Live'
    And I should see link 'Disable'



