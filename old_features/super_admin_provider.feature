@javascript @webmock_allow_localhost_connect

Feature: Provider Administration
  Background:
    As a super admin I want to be able to manage all providers.

Scenario: Check page based on the provider type
  Given I am a signed in super admin
   When I visit add new provider page
   Then I should see supplier number
    And I should see vat registered

Scenario Outline: Check when provider type button clicked that supplier number/vat registered are shown/hidden
  Given I am a signed in super admin
   When I visit add new provider page
    And I click on <radio_button> provider type
   Then I <supplier_number_expectation> see supplier number
    And I <vat_registered_expectation> see vat registered

  Examples:
    | radio_button | supplier_number_expectation| vat_registered_expectation |
    | Firm         | should                     | should                     |
    | Chamber      | should not                 | should not                 |
