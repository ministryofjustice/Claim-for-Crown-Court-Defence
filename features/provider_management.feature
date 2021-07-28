@javascript @no-seed @vat-seeds
Feature: Case worker can manage providers

  Scenario: A Provider manager can create a new chamber
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    Then the page should be accessible
    When I click the link 'Providers'
    Then I should be on the provider index page
    Then the page should be accessible

    When I click the link 'Add a provider'
    Then I should be on the new provider page
    Then the page should be accessible skipping 'aria-allowed-attr'

    When I fill in 'Provider name' with 'Test Chambers'
    And I choose govuk radio 'Chamber' for 'Provider type'
    Then I should not see 'AGFS'
    Then I should not see 'LGFS'

    When I click the button 'Save details'
    Then I should see 'Provider successfully created'
    And the page should be accessible

    And I eject the VCR cassette

  Scenario: A Provider manager can create a new firm
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    Then the page should be accessible
    When I click the link 'Providers'
    Then I should be on the provider index page

    When I click the link 'Add a provider'
    Then I should be on the new provider page

    When I fill in 'Provider name' with 'Test Chambers'
    And I choose govuk radio 'Firm' for 'Provider type'
    Then I should see 'AGFS'
    And I should see 'LGFS'

    And I click govuk checkbox 'LGFS'
    And I fill in 'Supplier number' with '1A234B'
    And I choose govuk radio 'Yes' for 'Is the provider VAT registered?'

    When I click the button 'Save details'
    Then I should see 'Provider successfully created'

    And I eject the VCR cassette

  Scenario: A Provider manager creates a new firm with errors and corrects
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    Then the page should be accessible
    When I click the link 'Providers'

    When I click the link 'Add a provider'
    Then I should be on the new provider page

    When I click the button 'Save details'
    Then I should see govuk error summary with 'Enter a provider name' linking to '#provider-name-field-error'
    Then I should see govuk error summary with 'Choose a provider type' linking to '#provider-provider-type-field-error'

    # TODO use cucumber table when field level erors are working too
    #
    # Then the following govuk error details should exist:
    #   | field_type | field_locator | error_text | linked_id |
    #   | fieldset | Provider type | blank | provider-provider-type-field-error |
    #   | field | Provider name | Enter a provider name | provider-name-field-error |
    #
    # NOTE: the following errors also appear on screen but should not because the user has not chosen a provider type at this point - namely roles (fee scheme) and LGFS supplier number presence

    When I choose govuk radio 'Firm' for 'Provider type'
    And I click govuk checkbox 'LGFS'
    And I fill in 'Supplier number' with '11111'

    When I click the button 'Save details'

    # TODO reimplement cucumber table when field level erors are working too
    #
    # Then the following govuk error details should exist:
    #   | field_type | field_locator | error_text | linked_id |
    #   | field | Provider name| Enter a provider name | provider-name-field-error |
    #   | field | Supplier number | Enter a valid LGFS supplier number | provider-lgfs-supplier-numbers-attributes-0-supplier-number-field-error |
    #   | fieldset | Is the provider VAT registered? | Choose VAT registration state | provider-vat-registered-field-error |

    When I fill in 'Provider name' with 'Test firm'
    And I fill in 'Supplier number' with '1A234B'
    And I choose govuk radio 'Yes' for 'Is the provider VAT registered?'
    And I click the button 'Save details'
    Then I should see 'Provider successfully created'

    And I eject the VCR cassette

  Scenario: A Provider manager can search for providers
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    And an external provider exists
    Then the page should be accessible

    When I click the link 'Providers'
    Then the page should be accessible
    And I click the link 'Find provider by email'
    Then I should be on the provider search page
    Then the page should be accessible

    When I enter 'test.user@chambers.com' in the email field
    And I click the search button
    Then I should see 'Manage user'
    Then the page should be accessible

    And I eject the VCR cassette

  Scenario: A Provider manager can create and update users on providers
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    And an external provider exists
    And I click the link 'Providers'
    And I click the link 'Manage users in provider'
    Then I should be on the provider manager user index page
    And the page should be accessible

    When I click the link 'Add user to provider'
    Then I should be on the provider manager user new page
    And the page should be accessible

    When I fill in 'First name' with 'David'
    And I fill in 'Last name' with 'Mann'
    And I fill in 'Email' with 'david.mann@example.com'
    And I fill in 'Email confirmation' with 'david.mann@example.com'
    And I click govuk checkbox 'Admin'
    And I click the button 'Create user'
    Then I should be on the provider manager user show page
    And I should see 'User successfully created'
    And the page should be accessible

    When I click the link 'Edit'
    Then I should be on the provider manager user edit page
    And the page should be accessible

    When I fill in 'First name' with 'Bob'
    And I fill in 'Email' with 'bob.mann@example.com'
    And I fill in 'Email confirmation' with 'bob.mann@example.com'
    And I click the button 'Update user'
    Then I should be on the provider manager user show page
    And I should see 'User successfully updated'

    And I eject the VCR cassette
