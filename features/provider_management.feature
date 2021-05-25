@javascript @no-seed @caseworker-seed-requirements
Feature: Case worker can manage providers

  Scenario: A provider Manager can create a new chamber
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    Then the page should be accessible
    When I click the link 'Providers'
    Then I should be on the provider index page
    Then the page should be accessible

    When I click the link 'Add a provider'
    Then I should be on the new provider page
    Then the page should be accessible skipping 'aria-allowed-attr'

    When I set the provider name to 'Test Chambers'
    And I choose govuk radio 'Chamber' for 'Provider type'
    Then I should not see 'AGFS'
    Then I should not see 'LGFS'

    When I click the Save details button
    Then I should see 'Provider successfully created'
    And the page should be accessible

    And I eject the VCR cassette

  Scenario: A provider Manager can create a new firm
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    Then the page should be accessible
    When I click the link 'Providers'
    Then I should be on the provider index page
    And the page should be accessible

    When I click the link 'Add a provider'
    Then I should be on the new provider page
    And the page should be accessible skipping 'aria-allowed-attr'

    When I set the provider name to 'Test Chambers'
    And I choose govuk radio 'Firm' for 'Provider type'
    Then I should see 'AGFS'
    And I should see 'LGFS'

    And I click govuk checkbox 'LGFS'
    And I set the supplier number to '1A234B'
    And I choose govuk radio 'Yes' for 'Is the provider VAT registered?'
    Then the page should be accessible skipping 'aria-allowed-attr'

    When I click the Save details button
    Then I should see 'Provider successfully created'
    Then the page should be accessible

    And I eject the VCR cassette

  Scenario: A provider Manager can search for providers
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
