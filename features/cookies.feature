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
