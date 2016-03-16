Feature: Advocate claim draft edit submit
  Background:
    Foo

  Scenario: foo
    Given I am a signed in advocate
    When I start a claim
    And I select a valid case number
    And I select Trial case type
    And I enter valid offence category
    And I enter defendant name and date of birth
    And I save as draft
