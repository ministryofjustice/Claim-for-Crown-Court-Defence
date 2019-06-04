@javascript
Feature: Case worker can manage providers

  Scenario: A provider Manager can create a new chamber
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    When I click the link 'Providers'
    Then I should be on the provider index page

    When I click the link 'Add a provider'
    Then I should be on the new provider page

    When I set the provider name to 'Test Chambers'
    And I set the provider type to 'Firm'
    Then I should see 'LGFS'
    Then I should see 'AGFS'
    When I set the provider type to 'Chamber'
    Then I should not see 'LGFS'
    When I select the 'AGFS' fee scheme
    When I click the Save details button
    Then I should see 'Provider successfully created'

    And I eject the VCR cassette

  Scenario: A provider Manager can search for providers
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    And an external provider exists

    When I click the link 'Providers'
    And I click the link 'Find provider by email'
    Then I should be on the provider search page

    When I enter 'test.user@chambers.com' in the email field
    And I click the search button
    Then I should see 'Manage user'

    And I eject the VCR cassette
