@javascript
Feature: Case worker can manage providers

  Scenario: A provider Manager can create a new chamber
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    Then the page should be accessible within "#content"
    When I click the link 'Providers'
    Then I should be on the provider index page
    Then the page should be accessible within "#content"

    When I click the link 'Add a provider'
    Then I should be on the new provider page
    Then the page should be accessible within "#content"

    When I set the provider name to 'Test Chambers'
    And I set the provider type to 'Firm'
    Then I should see 'LGFS'
    Then I should see 'AGFS'
    When I set the provider type to 'Chamber'
    Then I should not see 'LGFS'
    When I select the 'AGFS' fee scheme
    Then the page should be accessible within "#content"
    When I click the Save details button
    Then I should see 'Provider successfully created'
    Then the page should be accessible within "#content"

    And I eject the VCR cassette

  Scenario: A provider Manager can search for providers
    When I insert the VCR cassette 'features/provider_management'
    Given I am a signed in case worker provider manager
    And an external provider exists
    Then the page should be accessible within "#content"

    When I click the link 'Providers'
    Then the page should be accessible within "#content"
    And I click the link 'Find provider by email'
    Then I should be on the provider search page
    Then the page should be accessible within "#content"

    When I enter 'test.user@chambers.com' in the email field
    And I click the search button
    Then I should see 'Manage user'
    Then the page should be accessible within "#content"

    And I eject the VCR cassette
