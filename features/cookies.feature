Feature: Cookies

  Scenario: Accepting default cookies
    Given I visit "/"
    When I see the cookies banner
    And I click the link 'Accept analytics cookies'
    And I see the 'accepted analytics cookies' confirmation message
    And I click the link 'Hide this message'
    Then the cookie banner is not available

  Scenario: Rejecting default cookies
    Given I visit "/"
    When I see the cookies banner
    And I click the link 'Reject analytics cookies'
    And I see the 'rejected analytics cookies' confirmation message
    And I click the link 'Hide this message'
    Then the cookie banner is not available

  Scenario: Accepting cookies in cookies setting
    Given I visit "/"
    When I see the cookies banner
    And I click the link 'View cookies'
    And I choose to turn cookies 'on'
    And I click the button 'Save changes'
    Then the cookie preference is saved
    And the cookie banner is not available

  Scenario: Rejecting cookies in cookies setting
    Given I visit "/"
    When I see the cookies banner
    And I click the link 'View cookies'
    And I choose to turn cookies 'off'
    And I click the button 'Save changes'
    Then the cookie preference is saved
    And the cookie banner is not available
