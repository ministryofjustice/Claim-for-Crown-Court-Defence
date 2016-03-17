Feature: Advocate claim draft edit submit
  Background:
    Foo

  Scenario: foo
    Given I am a signed in advocate
    And I am on the new claim page
    And There are case types in place
    When I start a claim
    And I select an advocate category of 'Junior alone'
    And I select a court
    And I select a case type of 'Trial'
    And I enter a case number
    And I select an offence category
    And I enter defendant name and date of birth
    And I save as draft
