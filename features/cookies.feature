@no-seed
Feature: Cookies

  Scenario: Accepting default cookies
    Given I visit "/"
    When I see the cookies banner
    And I accept the cookies
    And I see the cookie confirmation message
    And I hide the cookie confirmation message
    Then the cookie banner is not available

  Scenario: Rejecting default cookies
    Given I visit "/"
    When I see the cookies banner
    And I reject the cookies
    And I see the cookie confirmation message
    And I hide the cookie confirmation message
    Then the cookie banner is not available

  Scenario: Accepting cookies in cookies setting
    Given I visit "/"
    When I see the cookies banner
    And I click to view cookies
    And I click the accept cookies radio button
    And I save changes to cookies
    Then the cookie preference is saved
    And the cookie banner is not available

  Scenario: Rejecting cookies in cookies setting
    Given I visit "/"
    When I see the cookies banner
    And I click to view cookies
    And I click the reject cookies radio button
    And I save changes to cookies
    Then the cookie preference is saved
    And the cookie banner is not available
