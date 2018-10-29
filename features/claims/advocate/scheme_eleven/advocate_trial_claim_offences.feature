@javascript
Feature: Advocate creates a claim for a final fee trial case under scheme 11

  Scenario: Successful renders scheme 11 offences
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a case number of 'A20181234'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter trial start and end dates

    Then I click "Continue" in the claim form

    And I enter defendant, scheme 11 representation order and MAAT reference
    Then I click "Continue" in the claim form

    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Then I should see 'Band: 8.1'
